defmodule GoogleAuthTest do
  use ExUnit.Case
  use Plug.Test
  import GoogleAuth.MockDataHelper, only: [mock_data: 0]

  test "adds google_auth_failure: 'Please send access token with request' key:value
    to private in Plug.Conn struct if no access_token is passed" do
    conn = call(conn(:get, "/"))
    google_auth_failure = conn.private.google_auth_failure
    assert google_auth_failure == "Please send access token with request"
  end

  test "adds google_auth_failure: Invalid access token key: value to private in Pluc.Conn
    struct if token is from the unknow client" do
    conn = call(conn(:get, "/?access_token=#{mock_data[:valid_token_from_unknow_client]}"))
    google_auth_failure = conn.private.google_auth_failure
    assert google_auth_failure == "Invalid access token"
  end

  test "adds errors to google_auth_failure key to private in Plug.Conn struct if error is
    returned from google" do
    conn = call(conn(:get, "/?access_token=#{mock_data[:error_token].access_token}"))
    google_auth_failure = conn.private.google_auth_failure
    assert google_auth_failure == mock_data[:error_token].message
  end

  test "adds google_auth_failure: 'Something went wrong' key: value in Plug.Conn struct if response
    is of format that is not handled" do
    conn = call(conn(:get,
      "/?access_token=#{mock_data[:unknow_user_details_response_format_token]}"))
    google_auth_failure = conn.private.google_auth_failure
    assert google_auth_failure == "Something went wrong"
  end

  test "adds google_auth_success key with user details if access_token is valid" do
    user_details = mock_data[:valid_token_data].first_token
    conn = call(conn(:get, "/?access_token=first_token"))
    google_auth_success = conn.private.google_auth_success
    assert google_auth_success.name == user_details.name
    assert google_auth_success.email == user_details.email
    assert google_auth_success.picture == user_details.picture
  end

  defp call(conn) do
    conn
      |> Plug.Parsers.call(Plug.Parsers.init(parsers: [Plug.Parsers.URLENCODED]))
      |> AccessTokenExtractor.call(AccessTokenExtractor.init([]))
      |> GoogleAuth.call(GoogleAuth.init([]))
  end
end
