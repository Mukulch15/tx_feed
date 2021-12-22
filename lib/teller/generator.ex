defmodule Teller.Generator do
  alias Teller.Factory

  def get_accounts(user_id) do
    [_, _, account_no_range] = String.split(user_id, "_")
    [number1, number2] = String.split(account_no_range, "-") |> Enum.map(fn x -> String.to_integer(x) end)
    institution_length = Enum.count(@institutions)
    names = Enum.map(number1..number2, fn x  ->
      {name, _} = Map.get(@accounts, "acc_#{x}" )
      name end)
    names_length = Enum.count(names)

    Enum.map(number1..number2, fn x ->
     %{
        "currency" => "USD",
        "enrollment_id" => "enr_#{x}",
        "id" => "acc_#{x}",
        "institution" => %{
          "id" =>
            "#{Recase.to_snake(Enum.at(@institutions, rem(x, institution_length)))}",
          "name" => Enum.at(@institutions, rem(x, institution_length))
        },
        "last_four" => "1757",
        "links" => %{
          "balances" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/balances",
          "details" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/details",
          "self" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000",
          "transactions" =>
            "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/transactions"
        },
        "name" => Enum.at(names, rem(x, names_length)),
        "subtype" => "checking",
        "type" => "depository"
      }
    end)
  end

  def get_account(id) do
    institution_length = Enum.count(@institutions)
    names = @accounts |> Map.values() |> Enum.map(fn {name, _} -> name end)
    names_length = Enum.count(names)

    [_, account_number] = String.split(id, "_")
    account_number = String.to_integer(account_number)

    %{
      "currency" => "USD",
      "enrollment_id" => "enr_#{Recase.to_snake(Enum.at(names, account_number))}",
      "id" => id,
      "institution" => %{
        "id" =>
          "#{Recase.to_snake(Enum.at(@institutions, rem(account_number, institution_length)))}",
        "name" => Enum.at(@institutions, rem(account_number, institution_length))
      },
      "last_four" => "1757",
      "links" => %{
        "balances" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/balances",
        "details" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/details",
        "self" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000",
        "transactions" =>
          "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/transactions"
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
        "account" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000",
        "self" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/details"
      },
      "routing_numbers" => %{
        "ach" => "586764187"
      }
    }
  end

  def get_account_balances(id) do
    {_, opening_balance} = Map.get(@accounts, id)
      string_opening_balance = to_string(opening_balance)

      %{
        "account_id" => id,
        "available" => string_opening_balance,
        "ledger" => string_opening_balance,
        "links" => %{
          "account" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000",
          "self" => "https://api.teller.io/accounts/acc_nrfdnf43t2m0euedfi000/balances"
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
    length_m = Enum.count(@merchants)
    length_c = Enum.count(@categories)
    {_, ob} = Map.get(@accounts, id)
    diff = Test.get_diff()
    [_, account_number] = String.split(id, "_")
    account_number = String.to_integer(account_number)

    Stream.map(1..diff, fn x ->
      tot = Enum.take(@amounts, x) |> get_sum()
      {date, amount} = Enum.at(@amounts, x - 1)
      tx_id = "#{account_number}-#{x}" |> Base.encode64()

      %{
        "account_id" => id,
        "amount" => Decimal.to_string(amount),
        "date" => date,
        "description" => "#{Enum.at(@merchants, rem(x, length_m))}",
        "details" => %{
          "category" => "#{Enum.at(@merchants, rem(x, length_c))}",
          "counterparty" => %{
            "name" => "#{Enum.at(@merchants, rem(x, length_c))}",
            "type" => "organization"
          },
          "processing_status" => "complete"
        },
        "id" => tx_id,
        "links" => %{
          "account" => "https://api.teller.io/accounts/acc_nmfff743stmo5n80t4000",
          "self" => "https://api.teller.io/accounts/acc_nmfff743stmo5n80t4000/transactions/"
        },
        "running_balance" => Decimal.to_string(Decimal.add(ob, tot)),
        "status" => "posted",
        "type" => "card_payment"
      }
    end)
    |> Enum.reverse()
  end

  def get_transaction(tx_id) do
    length_m = Enum.count(@merchants)
    length_c = Enum.count(@categories)

    [account_id, flag] =
      tx_id
      |> Base.decode64!()
      |> String.split("-")

    flag = String.to_integer(flag)
    {_, ob} = Map.get(@accounts, "acc_#{account_id}")
    tot = Enum.take(@amounts, flag) |> get_sum()
    {date, amount} = Enum.at(@amounts, flag - 1)

    %{
      "account_id" => account_id,
      "amount" => Decimal.to_string(amount),
      "date" => date,
      "description" => "#{Enum.at(@merchants, rem(flag, length_m))}",
      "details" => %{
        "category" => "#{Enum.at(@merchants, rem(flag, length_c))}",
        "counterparty" => %{
          "name" => "#{Enum.at(@merchants, rem(flag, length_c))}",
          "type" => "organization"
        },
        "processing_status" => "complete"
      },
      "id" => tx_id,
      "links" => %{
        "account" => "https://api.teller.io/accounts/acc_nmfff743stmo5n80t4000",
        "self" => "https://api.teller.io/accounts/acc_nmfff743stmo5n80t4000/transactions/"
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
