defmodule GoogleAuth.MockDataHelper do
  def mock_data do
    Application.get_env(:google_auth, :mock_data)
  end

  def valid_token_data do
    mock_data[:valid_token_data]
  end

  def valid_token do
    valid_token_data |> Map.keys |> List.first
  end

  def mocked_user_details do
    valid_token_data[valid_token]
  end

  def invalid_client_token do
    mock_data[:valid_token_from_unknow_client]
  end

  def error_token_data do
    Application.get_env(:google_auth, :mock_data)[:error_token]
  end
end

ExUnit.start()
