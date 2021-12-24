defmodule TellerWeb.Plugs.Authorise do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = conn.assigns[:user_id]
    [_, _, account_no_range] = String.split(user_id, "_")

    [number1, number2] =
      String.split(account_no_range, "-") |> Enum.map(fn x -> String.to_integer(x) end)

    account_id = conn.params["account_id"]
    transaction_id = conn.params["transaction_id"]

    with true <- valid_account_number?(account_id, number1..number2),
         true <- valid_transaction_id?(transaction_id, number1..number2) do
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
         true <- String.match?(account_id, ~r/^acc_\d+$/u) do
      [_, account_number] = String.split(account_id, "_")
      account_number = String.to_integer(account_number)

      if account_number not in account_number_range do
        false
      else
        true
      end
    else
      {:is_nil, true} ->
        true

      _ ->
        false
    end
  end

  defp valid_transaction_id?(transaction_id, account_number_range) do
    with {:is_nil, false} <- {:is_nil, is_nil(transaction_id)},
         {:ok, decoded_transaction_id} <- Base.decode64(transaction_id),
         [account_number, _] = String.split(decoded_transaction_id, "-"),
         account_number = String.to_integer(account_number),
         true <- account_number in account_number_range do
      true
    else
      :error ->
        false

      false ->
        false

      {:is_nil, true} ->
        true
    end
  end
end
