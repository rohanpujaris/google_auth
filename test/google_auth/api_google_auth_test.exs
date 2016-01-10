defmodule GoogleAuth.AuthRequestTest do
  use ExUnit.Case

  test "get_url(:token_info, access_token)" do
    access_token = "abc"
    token_info_url = GoogleAuth.AuthRequest.get_url(:token_info, access_token)
    assert token_info_url == "https://www.googleapis.com/oauth2/v2/tokeninfo?access_token=#{access_token}"
  end

  test "get_url(:user_details, access_token)" do
    access_token = "abc"
    token_info_url = GoogleAuth.AuthRequest.get_url(:user_details, access_token)
    assert token_info_url == "https://www.googleapis.com/oauth2/v2/userinfo?access_token=#{access_token}"
  end
end