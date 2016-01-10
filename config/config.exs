# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :google_auth, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:google_auth, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :google_auth, :mock_data,
  valid_token_data: %{
    first_token: %{name: "rohan", email: "rohan@gmail.com", picture: "http://a.com/pic.jpg"}
  },
  error_token: %{
    access_token: "invalid_credentials",
    message: "Invalid credentials"
  },
  valid_token_from_unknow_client: "unknown_token",
  unknow_user_details_response_format_token: "uudrft"

config :google_auth,
  google_client_id: "646252629386-aalvnktjfsql35e0cmb28qirhvj7t2p6.apps.googleusercontent.com"