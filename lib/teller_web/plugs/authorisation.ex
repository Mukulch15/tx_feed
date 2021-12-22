defmodule TellerWeb.Plugs.Authorise do
  alias Teller.Generator
  import Plug.Conn
  def init(opts), do: opts

  #Have to fix account id and tx formats.
  def call(conn, _opts) do
    user_id = conn.assigns[:user_id]
    [_, _, account_no_range] = String.split(user_id, "_")
    [number1, number2] = String.split(account_no_range, "-") |> Enum.map(fn x -> String.to_integer(x) end)
    account_id = conn.params["account_id"]
    verify_account_number(conn, account_id)
    if not is_nil(account_id) do
      [_, account_number] = String.split(account_id, "_")
      account_number = String.to_integer(account_number)
      IO.inspect account_number
      IO.inspect number1..number2
      if account_number not in number1..number2 do
        conn
        |> send_resp(404, "not found")
        |> halt()
      end
    end

    transaction_id = conn.path_params["transaction_id"]
    if not is_nil(transaction_id) do
      [account_number, _] = Base.decode64!(transaction_id) |> String.split("-")
      account_number = String.to_integer(account_number)
      if account_number not in number1..number2 do
        conn
        |> send_resp(404, "not found")
        |> halt()
      end
    end

    conn

  end

  defp verify_account_number(conn, account_id) do
    exists = Map.get(Generator.accounts(), account_id)

    if is_nil(exists) do
      conn
        |> send_resp(404, "not found")
        |> halt()
    end

  end

end
