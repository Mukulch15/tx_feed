defmodule Teller.Schemas.Account do
  @moduledoc false
  use Ecto.Schema
  @derive Jason.Encoder
  embedded_schema do
    field :currency, :string
    field :enrollment_id, :string
    field :last_four, :string
    field :name, :string
    field :subtype, :string
    field :type, :string
    embeds_one :institution, Teller.Schemas.Institutions
    embeds_one :routing_numbers, Teller.Schemas.Routing
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
    embeds_one :links, Teller.Schemas.Link
  end
end

defmodule Teller.Schemas.AccountDetails do
  use Ecto.Schema
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :account_id, :string
    field :account_number, :string
    embeds_one :routing_numbers, Teller.Schemas.Routing
    embeds_one :links, Link
  end
end
