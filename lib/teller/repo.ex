defmodule Teller.Repo do
  use Ecto.Repo,
    otp_app: :teller,
    adapter: Ecto.Adapters.Postgres
end
