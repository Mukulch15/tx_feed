defmodule TellerWeb.AccountController do
  alias Teller.Accounts
  alias Teller.Transactions
  use TellerWeb, :controller

  def index(conn, _params) do
    token = conn.assigns.token
    Phoenix.PubSub.broadcast(Teller.PubSub, token, :incr)
    accounts = Accounts.get_accounts(token)
    json(conn, %{accounts: accounts})
  end

  def show(conn, params) do
    token = conn.assigns.token
    Phoenix.PubSub.broadcast(Teller.PubSub, token, :incr)

    account = Accounts.get_account(params["account_id"])
    json(conn, %{account: account})
  end

  def get_account_details(conn, params) do
    token = conn.assigns.token
    Phoenix.PubSub.broadcast(Teller.PubSub, token, :incr)

    account = Accounts.get_account_details(params["account_id"])
    json(conn, %{account: account})
  end

  def get_account_balances(conn, params) do
    token = conn.assigns.token
    Phoenix.PubSub.broadcast(Teller.PubSub, token, :incr)

    account_balances = Accounts.get_account_balances(params["account_id"])
    json(conn, %{account_balances: account_balances})
  end

  def get_transactions(conn, params) do
    token = conn.assigns.token
    Phoenix.PubSub.broadcast(Teller.PubSub, token, :incr)

    transactions =
      Transactions.get_transactions(params["account_id"], params["from_id"], params["count"])

    json(conn, %{transactions: transactions})
  end

  def get_transaction(conn, params) do
    token = conn.assigns.token
    Phoenix.PubSub.broadcast(Teller.PubSub, token, :incr)

    transaction = Transactions.get_transaction(params["transaction_id"])
    json(conn, %{transaction: transaction})
  end
end
