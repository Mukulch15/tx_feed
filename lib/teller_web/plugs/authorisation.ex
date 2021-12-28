defmodule TellerWeb.Plugs.Authorise do
  @moduledoc """
    Authorisation plug for the apis.
    Authorises the api token, transaction_id and from_id parameters based on the token.
  """
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _opts) do
    token = conn.assigns[:token]
    [_, account_no_start] = String.split(token, "_")

    account_id = conn.params["account_id"]

    transaction_id = conn.params["transaction_id"]
    from_id = conn.params["from_id"]
    start = String.to_integer(account_no_start)
    till = String.to_integer(account_no_start) + 1

    with true <- valid_account_number?(account_id, start..till),
         true <- valid_transaction_id?(transaction_id, account_id),
         true <- valid_transaction_id?(from_id, account_id) do
      conn
    else
      false ->
        conn
        |> send_resp(404, "not found")
        |> halt()
    end
  end

  defp valid_account_number?(account_id, account_number_range) do
    with {:is_nil, false} <- {:is_nil, is_nil(account_id)},
         true <- String.match?(account_id, ~r/^acc_\d+$/u),
         [_, account_number] = String.split(account_id, "_"),
         account_number = String.to_integer(account_number),
         true <- account_number in account_number_range do
      true
    else
      {:is_nil, true} ->
        true

      _ ->
        false
    end
  end

  defp valid_transaction_id?(transaction_id, account_id) do
    with {:is_nil, false} <- {:is_nil, is_nil(transaction_id)},
         {:ok, decoded_transaction_id} <- Base.decode64(transaction_id),
         [account_number, _] = String.split(decoded_transaction_id, "-"),
         account_number = String.to_integer(account_number),
         true <- "acc_#{account_number}" == account_id do
      true
    else
      {:is_nil, true} ->
        true

      _ ->
        false
    end
  end
end
