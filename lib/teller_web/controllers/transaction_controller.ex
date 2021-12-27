defmodule TellerWeb.TransactionController do
  alias Teller.Transactions
  use TellerWeb, :controller

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
