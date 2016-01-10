defmodule GoogleAuth.AuthRequest do
  @google_urls [
    base_url: "https://www.googleapis.com/oauth2/v2",
    token_info: "/tokeninfo",
    user_details: "/userinfo"
  ]

  def get_url(api_path, access_token) do
    "#{@google_urls[:base_url]}#{@google_urls[api_path]}?access_token=#{access_token}"
  end

  def token_info(access_token) do
    response = HTTPotion.get(get_url(:token_info, access_token))
    Poison.decode(response.body)
  end

  def user_details(access_token) do
    response = HTTPotion.get(get_url(:user_details, access_token))
    Poison.decode(response.body)
  end
end
