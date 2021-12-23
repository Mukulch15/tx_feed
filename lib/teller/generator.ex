defmodule Teller.Generator do
  alias Teller.Factory

  def get_accounts(user_id) do
    [_, _, account_no_range] = String.split(user_id, "_")

    [number1, number2] =
      String.split(account_no_range, "-") |> Enum.map(fn x -> String.to_integer(x) end)

    Enum.map(number1..number2, fn x ->
      get_account("acc_#{x}")
    end)
  end

  def get_account(id) do
    institution_length = Enum.count(Factory.institutions_data())
    names = Factory.accounts_constant_data() |> Map.values() |> Enum.map(fn {name, _} -> name end)
    names_length = Enum.count(names)

    [_, account_number] = String.split(id, "_")
    account_number = String.to_integer(account_number)

    %{
      "currency" => "USD",
      "enrollment_id" => "enr_#{account_number}",
      "id" => id,
      "institution" => %{
        "id" =>
          "#{Recase.to_snake(Enum.at(Factory.institutions_data(), rem(account_number, institution_length)))}",
        "name" => Enum.at(Factory.institutions_data(), rem(account_number, institution_length))
      },
      "last_four" => "1757",
      "links" => %{
        "balances" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}/balances",
        "details" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}/details",
        "self" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}",
        "transactions" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}/transactions"
      },
      "name" => Enum.at(names, rem(account_number, names_length)),
      "subtype" => "checking",
      "type" => "depository"
    }
  end

  def get_account_details(id) do
    [_, account_number] = String.split(id, "_")

    %{
      "account_id" => id,
      "account_number" => account_number,
      "links" => %{
        "account" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}",
        "self" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}/details"
      },
      "routing_numbers" => %{
        "ach" => "586764187"
      }
    }
  end

  def get_account_balances(id) do
    {_, opening_balance} = Map.get(Factory.accounts_constant_data(), id)
    string_opening_balance = to_string(opening_balance)

    %{
      "account_id" => id,
      "available" => string_opening_balance,
      "ledger" => string_opening_balance,
      "links" => %{
        "account" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}",
        "self" => "#{TellerWeb.Endpoint.url()}/accounts/#{id}/balances"
      }
    }
  end

  def get_transactions(id, nil, _count) do
    _get_transactions(id)
  end

  def get_transactions(id, tx_id, count) do
    lst =
      _get_transactions(id)
      |> Stream.map(fn %{"id" => id} = x -> {id, x} end)
      |> Stream.chunk_by(fn {id, _} -> id == tx_id end)
      |> Enum.to_list()

    [f, s, t] = lst
    [h | _] = :lists.reverse(f)

    case count do
      1 ->
        [h] ++ s

      0 ->
        h

      nil ->
        [h] ++ s ++ t

      n ->
        [h] ++ s ++ Enum.take(t, n - 1)
    end
    |> Stream.map(fn {_, tx} -> tx end)
    |> Enum.to_list()
  end

  defp _get_transactions(id) do
    diff = Test.get_diff()
    [_, account_number] = String.split(id, "_")
    account_number = String.to_integer(account_number)

    Stream.map(1..diff, fn x ->
      tx_id = "#{account_number}-#{x}" |> Base.encode64()
      get_transaction(tx_id)
    end)
    |> Enum.reverse()
  end

  def get_transaction(tx_id) do
    length_m = Enum.count(Factory.merchants_data())
    length_c = Enum.count(Factory.categories_data())

    [account_number, flag] =
      tx_id
      |> Base.decode64!()
      |> String.split("-")

    account_id = "acc_#{account_number}"
    flag = String.to_integer(flag)
    {_, ob} = Map.get(Factory.accounts_constant_data(), account_id)
    tot = Enum.take(Factory.amounts_data(), flag) |> get_sum()
    {date, amount} = Enum.at(Factory.amounts_data(), flag - 1)

    %{
      "account_id" => account_id,
      "amount" => Decimal.to_string(amount),
      "date" => date,
      "description" => "#{Enum.at(Factory.merchants_data(), rem(flag, length_m))}",
      "details" => %{
        "category" => "#{Enum.at(Factory.merchants_data(), rem(flag, length_c))}",
        "counterparty" => %{
          "name" => "#{Enum.at(Factory.merchants_data(), rem(flag, length_c))}",
          "type" => "organization"
        },
        "processing_status" => "complete"
      },
      "id" => tx_id,
      "links" => %{
        "account" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
        "self" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/transactions/#{tx_id}"
      },
      "running_balance" => Decimal.to_string(Decimal.add(ob, tot)),
      "status" => "posted",
      "type" => "card_payment"
    }
  end

  defp get_sum(lst) do
    Enum.reduce(lst, Decimal.new(0), fn {_, x}, acc -> Decimal.add(x, acc) end)
    |> Decimal.negate()
  end
end
