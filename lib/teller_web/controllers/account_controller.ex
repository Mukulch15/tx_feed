defmodule TellerWeb.AccountController do
  alias Teller.Accounts
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
end
