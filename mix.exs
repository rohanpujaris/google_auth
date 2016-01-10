defmodule GoogleAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :google_auth,
     version: "0.0.1",
     description: description,
     package: packages,
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:module_mocker, "~> 0.2.0"},
     {:access_token_extractor, "~> 0.1.0"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end

  defp description do
    """
    Simple Plug to provide google based authentication. Just pass access_token received
    from client side google auth flow and this plug will get name, emai and picture
    of user from google and add it to private inside Plug.Conn
    """
  end

  defp packages do
    [
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Rohan Pujari"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rohanpujaris/google_auth"}
    ]
  end
end
