defmodule Teller.Transactions do
  alias Teller.Factory
  alias Teller.Helpers
  alias Teller.Schemas.{Transaction, TransactionCounterParty, TransactionDetails}

  # TODO
  # 1. Write documentation.
  # 2. Write tests.

  def get_transactions(account_id, nil, _count) do
    _get_transactions(account_id)
  end

  def get_transactions(account_id, from_id, count) do
    _get_transactions(account_id)
    |> Enum.chunk_by(fn tx -> tx.id == from_id end)
    |> Enum.to_list()
    |> Helpers.paginate_transactions(count)
  end

  defp _get_transactions(account_id) do
    diff = Helpers.get_diff()
    [_, account_number] = String.split(account_id, "_")
    account_number = String.to_integer(account_number)

    Enum.map(1..diff, fn x ->
      tx_id = "#{account_number}-#{x}" |> Base.encode64()
      get_transaction(tx_id)
    end)
  end

  def get_transaction(tx_id) do
    length_m = Enum.count(Factory.merchants())
    length_c = Enum.count(Factory.categories())

    [account_number, flag] =
      tx_id
      |> Base.decode64!()
      |> String.split("-")

    account_id = "acc_#{account_number}"
    opening_balance = Decimal.new(:erlang.phash2(account_id))
    flag = String.to_integer(flag)
    {lst, _} = Helpers.calculate_date_amounts(opening_balance)
    tot = Enum.take(lst, flag) |> Helpers.get_sum()
    {date, amount} = Enum.at(lst, flag - 1)

    %Transaction{
      account_id: account_id,
      amount: Decimal.to_string(amount),
      date: date,
      description: "#{Enum.at(Factory.merchants(), rem(flag, length_m))}",
      details: %TransactionDetails{
        category: "#{Enum.at(Factory.categories(), rem(flag, length_c))}",
        counterparty: %TransactionCounterParty{
          name: "#{Enum.at(Factory.merchants(), rem(flag, length_m))}",
          type: "organization"
        },
        processing_status: "complete"
      },
      id: tx_id,
      links: %Teller.Schemas.Link{
        account: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
        self: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/transactions/#{tx_id}"
      },
      running_balance: Decimal.to_string(Decimal.add(opening_balance, tot)),
      status: "posted",
      type: "card_payment"
    }
  end
end
