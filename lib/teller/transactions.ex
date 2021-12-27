defmodule Teller.Transactions do
  @moduledoc """
    This modules consists of functions that generate transaction related data like transaction feed and
    a specific transaction. The transactions start from the date ~D[2021-09-19].
  """
  alias Teller.Factory
  alias Teller.Helpers
  alias Teller.Schemas.{Transaction, TransactionCounterParty, TransactionDetails}

  @doc """
    This overloaded function generates transaction feed using account_id.
    It accepts three parameters account_id, from_id and count.
    from_id is the transaction_id from where to start the feed
    and count limits the length of feed. Hence these two parameters
    are used for pagination.
    In a paginated result the first transaction of the feed will be
    the previous transaction of from_id.
    It returns the entire feed if from_id and count is nil.
    The transaction is generated from account_number and the sequence number of the transaction in the feed.
    This makes it easier to get the account_id of a transaction.
  """
  def get_transactions(account_id, nil, nil) do
    _get_transactions(account_id)
    |> :lists.reverse()
    |> Enum.take(90)
    |> :lists.reverse()
  end

  def get_transactions(account_id, from_id, count) do
    _get_transactions(account_id)
    |> Enum.chunk_by(fn tx -> tx.id == from_id end)
    |> Enum.to_list()
    |> Helpers.paginate_transactions(count)
  end

  def _get_transactions(account_id) do
    diff = Helpers.get_diff()
    [_, account_number] = String.split(account_id, "_")
    account_number = String.to_integer(account_number)

    Enum.map(1..diff, fn x ->
      tx_id = "#{account_number}-#{x}" |> Base.encode64()
      get_transaction(tx_id)
    end)
  end

  @doc """
    This functions fetches the details of a single transaction using its transaction_id.
    The transaction id is basically an encoded form of account_id and the trsnaction's sequence number.
    This makes it easier to generate account details using transaction_id making the implementation simpler and effecient.
  """
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
    salt = Decimal.new(Helpers.get_salt(account_id))
    # Fetches a list containing datewise transaction amounts
    {lst, _} = Helpers.calculate_date_amounts(opening_balance, salt)
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
