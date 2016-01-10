defmodule GoogleAuth.Mock.AuthRequest do
  @moduledoc false

  def token_info_response(client \\ :invalid_client) do
    if client == :valid_client do
      client_id = Application.get_env(:google_auth, :google_client_id)
    else
      client_id = "407408718192.apps.googleusercontent.com"
    end
    %{"issued_to" => client_id}
  end


  def error_response do
    %{
      "error" => %{
        "message" => get_mock_data[:error_token].message
       }
    }
  end

  def token_info(access_token) do
    token_data = get_mock_token_data(access_token)
    cond do
      token_data ->
        {:ok, token_info_response(:valid_client)}
      access_token == get_mock_data[:error_token].access_token ->
        {:ok, token_info_response(:valid_client)}
      access_token == get_mock_data[:unknow_user_details_response_format_token] ->
        {:ok, token_info_response(:valid_client)}
      access_token == get_mock_data[:valid_token_from_unknow_client] ->
        {:ok, token_info_response}
      :else -> :error
    end
  end

  def user_details(access_token) do
    user_details = get_mock_token_data(access_token)
    if user_details do
      user_details = Enum.reduce(user_details, %{},
        fn ({key, val}, acc) -> Map.put(acc, Atom.to_string(key), val) end)
    end
    cond do
      user_details ->
        {:ok, user_details}
      access_token == get_mock_data[:error_token].access_token ->
        {:ok, error_response}
      :else -> %{unknow_format: %{}}
    end
  end

  defp get_mock_data do
    Application.get_env(:google_auth, :mock_data)
  end

  defp get_mock_token_data(access_token) do
    get_mock_data[:valid_token_data][String.to_atom(access_token)]
  end
end
