defmodule Mock.GoogleAuthTest do
  use ExUnit.Case
  use Plug.Test
  import GoogleAuth.MockDataHelper,
    except: [invalid_client_token: 0, error_token_data: 0]


  test "adds google_auth_success key with value as user_details when
    token is from valid_token_data in config" do
    conn = call(conn(:get, "/?access_token=#{valid_token}"))
    google_auth_success = conn.private.google_auth_success
    assert google_auth_success.name == mocked_user_details.name
    assert google_auth_success.email == mocked_user_details.email
    assert google_auth_success.picture == mocked_user_details.picture
  end

  test "add google_auth_failure with error message when token is
    specified as error_token inside config" do
    error_token_data = mock_data[:error_token]
    conn = call(conn(:get, "/?access_token=#{error_token_data.access_token}"))
    google_auth_failure = conn.private.google_auth_failure
    assert google_auth_failure == error_token_data.message
  end

  test "add google_auth_failure with value 'Invalid access token' if access_token is invalid" do
    conn = call(conn(:get, "/?access_token=invalid_token"))
    google_auth_failure = conn.private.google_auth_failure
    assert google_auth_failure == "Invalid access token"
  end

  defp call(conn) do
    conn
      |> Plug.Parsers.call(Plug.Parsers.init(parsers: [Plug.Parsers.URLENCODED]))
      |> AccessTokenExtractor.call(AccessTokenExtractor.init([]))
      |> GoogleAuth.call(GoogleAuth.init([]))
  end
end