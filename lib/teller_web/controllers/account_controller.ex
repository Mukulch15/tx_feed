defmodule TellerWeb.AccountController do
  alias Teller.Generator
  use TellerWeb, :controller

  def index(conn, _params) do
    Phoenix.PubSub.broadcast(Teller.PubSub, "user:123", :incr)
    user_id = conn.assigns[:user_id]
    accounts = Generator.get_accounts(user_id)
    json(conn, %{accounts: accounts})
  end

  def show(conn, params) do
    Phoenix.PubSub.broadcast(Teller.PubSub, "user:123", :incr)

    case Generator.get_account(params["account_id"]) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})

      account ->
        json(conn, %{account: account})
    end
  end

  def get_account_details(conn, params) do
    Phoenix.PubSub.broadcast(Teller.PubSub, "user:123", :incr)

    case Generator.get_account_details(params["account_id"]) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})

      account ->
        json(conn, %{account: account})
    end
  end

  def get_account_balances(conn, params) do
    Phoenix.PubSub.broadcast(Teller.PubSub, "user:123", :incr)

    case Generator.get_account_balances(params["account_id"]) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})

      account_balance ->
        json(conn, %{account_balance: account_balance})
    end
  end

  def get_transactions(conn, params) do
    Phoenix.PubSub.broadcast(Teller.PubSub, "user:123", :incr)

    case Generator.get_transactions(params["account_id"], params["from_id"], params["count"]) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})

      transactions ->
        json(conn, %{transactions: transactions})
    end
  end

  def get_transaction(conn, params) do
    Phoenix.PubSub.broadcast(Teller.PubSub, "user:123", :incr)

    case Generator.get_transaction(params["transaction_id"]) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{})

      transaction ->
        json(conn, %{transaction: transaction})
    end
  end
end
