defmodule GoogleAuth do
  @moduledoc """
  GoogleAuth package provide a simple google based authentication.
  It does not provide the request phase( ie. Authentication url), it just implements the callback phase.
  You just need to pass google access_token received from google using google client side authentication.
  Using [Google api client library](https://developers.google.com/api-client-library/javascript/features/authentication)
  you can generate access token on client side and pass it to a server.
  You can pass access_token as a query params or in headers

  Example:

    http://some_url.com?access_token=abc

    OR

    authorization: Token token=abc


  When no access_token is passed to server then 'google_auth_failure' key will be added with value
  "Please send access token with request" to private inside Plug.Conn struct.

  GoogleAuth plug will verify whether the token is valid and is generated using the
  google client id mentioned in the config files. If it is valid it will add 'google_auth_success'
  key with value as a map containing user name, email and picture url to private map inside
  Plug.Conn struct

  If token passed is not valid it will add 'google_auth_failure' key with value consisting of
  error message in private inside Plug.Conn.

  You need to add following config in to make GoogleAuth plug work.

      config :google_auth,
        google_client_id: "646252629386-aalvnktjfsql35e0cmb28qirhvj7t2p.apps.googleusercontent.com"

  Above is the google client id that we get when we register the oauth client at google.
  Access token will only be valid if its generated using above clien id.


  ### Usage with phoenix framework:

      # Inside routes.ex

      get "/google_auth/callback", GoogleAuthController, :callback


      # Inside controller

      defmodule GoogleAuthController do
        use MyApp.Web, :controller
        use GoogleAuth

        def callback(%Plug.Conn{private: %{google_auth_success: user_details}} = conn, _) do
          # user_details will be like %{name: "rohan", email: "rohan@gmail.com", picture: "http://a/b.jpg"}
        end

        def callback(%Plug.Conn{private: %{google_auth_failure: error_message}} = conn, _) do
          conn
            |> put_status(401)
            |> json %{error: error_message}
        end
      end


  ### Testing:

    During testing run GoogleAuth module is not used and instead Mock.GooogleAuth module is used.
    This package comes with Mock.GooogleAuth which provide mocking.
    To test the controller that uses GoogleAuth plug, you simply need to add mock data inside
    config/test.exs. Mock data must be in following format.

    Format:
      config :google_auth, :mock_data,
        valid_token_data: %{
          first_token: %{name: "rohan", email: "rohan@gmail.com", picture: "http://a.com/pic.jpg"},
          second_token: %{name: "raj", email: "raj@gmail.com", picture: "http://a.com/pic1.jpg"}
        }
      config :google_auth,
        google_client_id: "646252629386-aalvnktjfsql35e0cmb28qirhvj7t2p.apps.googleusercontent.com"

    'first_token' and 'second_token' represent the valid access_token which will.
    Passing 'first_token' as access_token in test will add
    %{name: "rohan", email: "rohan@gmail.com", picture: "http://a.com/pic.jpg"} to 'google_auth_success'
    private key inside Plug.Conn struct.

    While testing use 'first_token' or 'second_token' as a valid access_token.

    Example test case:

      test "creates a user record when auth sucessfull"do
        user_mock_data = Application.get_ev(:google_auth, :mock_date)[:valid_token_data].first_token
        get conn(), "/api/v1/google_auth/callback?access_token=first_token"
        user = Repo.one(User |> order_by(desc: :updated_at) |> limit(1))
        assert user.name == user_mock_data.name
        assert user.email == user_mock_data.email
        assert user.picture == user_mock_data.picture
      end

    Any other token which are not keys of valid_toke_data map will be treated as invalid token and
    will add 'google_auth_failure' with value "Invalid access token".
    You can also create Mock.GoogleAuth in your project if default mocking provided by this
    package is not sufficient.
  """
  import Plug.Conn
  import ModuleMocker

  mock_for_test GoogleAuth.AuthRequest

  def init(_) do
  end

  def call(conn, _) do
    verify_token_and_get_user_details(conn)
  end

  @doc """
  Checks whether access token is valid and is issued_to google client id mentioned in config file.
  If token is valid will send request to google to get user details
  """
  def verify_token_and_get_user_details(%Plug.Conn{private: %{access_token: access_token}}=conn) do
    google_client_id = Application.get_env(:google_auth, :google_client_id)
    case @auth_request.token_info(access_token) do
      {:ok, %{"issued_to" => ^google_client_id}} -> getUserDetails(conn)
      _ -> put_private(conn, :google_auth_failure, "Invalid access token")
    end
  end

  @doc """
  If no access_token is passed the add private key google_auth_failure with value
  "Please send access token with request"
  """
  def verify_token_and_get_user_details(conn) do
    put_private(conn, :google_auth_failure, "Please send access token with request")
  end

  @doc """
  Send request to google to get users details. If token is valid and ther were no issues in
  retrieving user details, user details will be added to 'google_auth_success' private key inside
  Plug.Conn struct.
  User details added is a map consisting of name, email and picture keys with details as value.
  """
  def getUserDetails(%Plug.Conn{private: %{access_token: access_token}} = conn) do
    case @auth_request.user_details(access_token) do
      {:ok, %{"email" => email, "name" => name, "picture" => picture}} ->
        put_private(conn, :google_auth_success, %{name: name, email: email, picture: picture})
      {:ok, %{"error" => %{"message" => error_message}}} ->
        put_private(conn, :google_auth_failure, error_message)
      _ ->
        put_private(conn, :google_auth_failure, "Something went wrong")
    end
  end

  @doc """
  Add plug AccessTokenExtractor and GoogleAuth.
  GoogleAuth is authomatically mocked during testing. While running test GoogleAuth module
  would not be used instead Mock.GoogleAuth module would be used.
  """
  defmacro __using__(_) do
    quote do
      import ModuleMocker
      mock_for_test GoogleAuth
      plug AccessTokenExtractor
      plug @google_auth
    end
  end
end
