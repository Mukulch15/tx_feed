defmodule Teller.Accounts do
  alias Teller.Factory
  alias Teller.Helpers

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

    %{
      "currency" => "USD",
      "enrollment_id" => "enr_#{Base.encode64(account_id)}",
      "id" => account_id,
      "institution" => %{
        "id" =>
          "#{Recase.to_snake(Enum.at(Factory.institutions(), rem(hashed_account_id, institution_length)))}",
        "name" => Enum.at(Factory.institutions(), rem(hashed_account_id, institution_length))
      },
      "last_four" => last_four,
      "links" => %{
        "balances" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/balances",
        "details" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/details",
        "self" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
        "transactions" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/transactions"
      },
      "name" => Enum.at(names, rem(hashed_account_id, names_length)),
      "subtype" => "checking",
      "type" => "depository"
    }
  end

  def get_account_details(account_id) do
    [_, account_number] = String.split(account_id, "_")

    %{
      "account_id" => account_id,
      "account_number" => account_number,
      "links" => %{
        "account" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
        "self" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/details"
      },
      "routing_numbers" => %{
        "ach" => account_id |> :erlang.phash2() |> :erlang.phash2()
      }
    }
  end

  def get_account_balances(account_id) do
    opening_balance = Decimal.new(:erlang.phash2(account_id))
    {_, available} = Helpers.calculate_date_amounts(Decimal.new(opening_balance))

    %{
      "account_id" => account_id,
      "available" => "#{available}",
      "ledger" => "#{available}",
      "links" => %{
        "account" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}",
        "self" => "#{TellerWeb.Endpoint.url()}/accounts/#{account_id}/balances"
      }
    }
  end
end
