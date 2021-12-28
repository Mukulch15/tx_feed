defmodule Teller.Schemas.Link do
  @moduledoc false
  use Ecto.Schema
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :balances, :string
    field :self, :string
    field :details, :string
    field :transactions, :string
    field :account, :string
  end
end
