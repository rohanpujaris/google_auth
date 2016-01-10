defmodule Mock.GoogleAuth do
  @moduledoc false

  import Plug.Conn

  def init(_) do
  end

  def call(%Plug.Conn{private: %{access_token: access_token}}=conn, _) do
    mock_data = Application.get_env(:google_auth, :mock_data)
    user_details =  mock_data[:valid_token_data][String.to_atom(access_token)]
    cond do
      user_details ->
        put_private(conn, :google_auth_success, user_details)
      mock_data[:error_token] && access_token == mock_data[:error_token].access_token ->
        put_private(conn, :google_auth_failure, mock_data[:error_token].access_token)
      :else ->
        put_private(conn, :google_auth_failure, "Invalid access token")
    end
  end

  def call(conn, _) do
    put_private(conn, :google_auth_failure, "Please send access token with request")
  end
end