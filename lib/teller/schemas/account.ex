defmodule Teller.Schemas.Account do
  use Ecto.Schema
  @derive Jason.Encoder
  embedded_schema do
    field :currency, :string
    field :enrollment_id, :string
    field :account_number, :string
    field :last_four, :string
    field :name, :string
    field :subtype, :string
    field :type, :string
    embeds_one :institution, Institution
    embeds_one :routing_numbers, Routing
    embeds_one :links, Link
  end
end

defmodule Teller.Schemas.AccountBalances do
  use Ecto.Schema
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :available, :string
    field :ledger, :string
    field :account_id, :string
    embeds_one :links, Link
  end
end

defmodule Teller.Schemas.AccountDetails do
  use Ecto.Schema
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :account_id, :string
    field :account_number, :string
    embeds_one :routing_numbers, Routing
    embeds_one :links, Link
  end
end

defmodule Teller.Schemas.Institution do
  use Ecto.Schema
  @derive Jason.Encoder
  embedded_schema do
    field :name, :string
  end
end

defmodule Teller.Schemas.Link do
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

defmodule Teller.Schemas.Routing do
  use Ecto.Schema
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :ach, :string
  end
end
