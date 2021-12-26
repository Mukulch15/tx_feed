defmodule Teller.Accounts do
  alias Teller.Factory
  alias Teller.Helpers
  alias Teller.Schemas.{Account, AccountDetails, AccountBalances, Institution, Link, Routing}

  def get_accounts(token) do
    [String.split(token, "_")]
    |> Enum.reduce(nil, fn [_, acc_no_start], _acc ->
      String.to_integer(acc_no_start)..(String.to_integer(acc_no_start) + 1)
    end)
    |> Enum.map(fn x ->
      get_account("acc_#{x}")
    end)
  end

  def get_account(account_id) do
    hashed_account_id = :erlang.phash2(account_id)
    institution_length = Enum.count(Factory.institutions())
    names = Factory.account_names()
    names_length = Enum.count(Factory.account_names())
    last_four = String.slice(account_id, 12..-1)
    account_number = String.trim_leading(account_id, "acc_")

    %Account{
      currency: "USD",
      enrollment_id: "enr_#{Base.encode64(account_id)}",
      id: account_id,
      institution: %Institution{
        id:
          "#{Recase.to_snake(Enum.at(Factory.institutions(), rem(hashed_account_id, institution_length)))}",
        name: Enum.at(Factory.institutions(), rem(hashed_account_id, institution_length))
      },
      last_four: last_four,
      account_number: account_number,
      links: %Link{
        balances: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/balances",
        details: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/details",
        self: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
        transactions: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/transactions"
      },
      routing_numbers: %Routing{
        ach: account_id |> :erlang.phash2() |> :erlang.phash2()
      },
      name: Enum.at(names, rem(hashed_account_id, names_length)),
      subtype: "checking",
      type: "depository"
    }
  end

  def get_account_details(account_id) do
    links = %Link{
      account: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
      self: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/details"
    }

    account_number = String.trim_leading(account_id, "acc_")

    routing_numbers = %Routing{
      ach: account_id |> :erlang.phash2() |> :erlang.phash2() |> to_string()
    }

    %AccountDetails{
      account_id: account_id,
      account_number: account_number,
      links: links,
      routing_numbers: routing_numbers
    }
  end

  def get_account_balances(account_id) do
    links = %Link{
      account: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
      self: "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/balances"
    }

    opening_balance = Decimal.new(:erlang.phash2(account_id))
    {_, available} = Helpers.calculate_date_amounts(Decimal.new(opening_balance))

    %AccountBalances{
      available: available,
      ledger: available,
      links: links,
      account_id: account_id
    }
  end
end
