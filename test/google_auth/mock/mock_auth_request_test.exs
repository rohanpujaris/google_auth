defmodule GoogleAuth.Mock.AuthRequestTest do
  use ExUnit.Case
  import GoogleAuth.MockDataHelper
  alias GoogleAuth.Mock.AuthRequest

  test "token_info_response() not equals google_client_id from config file" do
    token_info_response = AuthRequest.token_info_response
    assert token_info_response["issued_to"] != Application.get_env(:google_auth, :google_client_id)
  end


  test "token_info_response(:valid_client) equals google_client_id from config file" do
    token_info_response = AuthRequest.token_info_response(:valid_client)
    assert token_info_response["issued_to"] == Application.get_env(:google_auth, :google_client_id)
  end

  test "token_info(access_token) should return google_client_id from config as issued_to when
    token is provided from client mentioned in config google_client_id" do
    {:ok, token_info} = AuthRequest.token_info(Atom.to_string(valid_token))
    assert token_info["issued_to"] == Application.get_env(:google_auth, :google_client_id)
  end

  test "token_info(access_token) should not return google_client_id from config as issued_to
    when token is provided by client that is not same as mentioned in config google_client_id" do
    {:ok, token_info} = AuthRequest.token_info(invalid_client_token)
    assert token_info["issued_to"] != Application.get_env(:google_auth, :google_client_id)
  end

  test "user_details(access_token) should return user name email and picture url
    if token is from valid_token_data in config" do
    {:ok, user_details} = AuthRequest.user_details(Atom.to_string(valid_token))
    mocked_user_details = mocked_user_details
    assert user_details["name"] == mocked_user_details.name
    assert user_details["email"] == mocked_user_details.email
    assert user_details["picture"] == mocked_user_details.picture
  end

  test "user_details(access_token) should return error_response if access_token is
    in error_token in config" do
    error_token_data = error_token_data
    {:ok, user_details} = AuthRequest.user_details(error_token_data.access_token)
    assert user_details == AuthRequest.error_response
  end
end