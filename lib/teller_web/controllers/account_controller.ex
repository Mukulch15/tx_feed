defmodule TellerWeb.AccountController do
  alias Teller.Generator
  use TellerWeb, :controller

  def index(conn, _params) do
    user_id = conn.assigns.user_id
    Phoenix.PubSub.broadcast(Teller.PubSub, user_id, :incr)
    user_id = conn.assigns[:user_id]
    accounts = Generator.get_accounts(user_id)
    json(conn, %{accounts: accounts})
  end

  def show(conn, params) do
    user_id = conn.assigns.user_id
    Phoenix.PubSub.broadcast(Teller.PubSub, user_id, :incr)

    account = Generator.get_account(params["account_id"])
    json(conn, %{account: account})
  end

  def get_account_details(conn, params) do
    user_id = conn.assigns.user_id
    Phoenix.PubSub.broadcast(Teller.PubSub, user_id, :incr)

    account = Generator.get_account_details(params["account_id"])
    json(conn, %{account: account})
  end

  def get_account_balances(conn, params) do
    user_id = conn.assigns.user_id
    Phoenix.PubSub.broadcast(Teller.PubSub, user_id, :incr)

    account_balances = Generator.get_account_balances(params["account_id"])
    json(conn, %{account_balances: account_balances})
  end

  def get_transactions(conn, params) do
    user_id = conn.assigns.user_id
    Phoenix.PubSub.broadcast(Teller.PubSub, user_id, :incr)

    transactions =
      Generator.get_transactions(params["account_id"], params["from_id"], params["count"])

    json(conn, %{transactions: transactions})
  end

  def get_transaction(conn, params) do
    user_id = conn.assigns.user_id
    Phoenix.PubSub.broadcast(Teller.PubSub, user_id, :incr)

    transaction = Generator.get_transaction(params["transaction_id"])
    json(conn, %{transaction: transaction})
  end
end
