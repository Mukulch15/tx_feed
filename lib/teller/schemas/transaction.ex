defmodule Teller.Schemas.Transaction do
  use Ecto.Schema
  @derive Jason.Encoder
  embedded_schema do
    field :account_id, :string
    field :amount, :string
    field :date, :date
    field :description, :string
    field :running_balance, :string
    field :status, :string
    field :type, :string
    embeds_one :details, TransactionDetails
    embeds_one :links, Teller.Schemas.Link
  end
end

defmodule Teller.Schemas.TransactionDetails do
  use Ecto.Schema
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :category, :string
    field :processing_status, :string
    embeds_one :counterparty, TransactionCounterParty
  end
end

defmodule Teller.Schemas.TransactionCounterParty do
  use Ecto.Schema
  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :name, :string
    field :type, :string
  end
end
