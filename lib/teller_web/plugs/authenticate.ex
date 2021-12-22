defmodule TellerWeb.Plugs.Authenticate do
  import Plug.Conn
  @realm "Basic realm=\"Dashboard\""
  @users ["dGVzdF91c2VyMV8xMjM0NTY3ODkwMC0xMjM0NTY3ODkwMjo=", "dGVzdF91c2VyMV8xMjM0NTY3ODkwMy0xMjM0NTY3ODkwNTo=", "dGVzdF91c2VyMV8xMjM0NTY3ODkwNi0xMjM0NTY3ODkwNzo="]
  # @users ["mu"]
  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> attempted_auth] ->
        verify(conn, attempted_auth)

      _ ->
        unauthorized(conn)
    end
  end

  defp verify(conn, attempted_auth) do
    case attempted_auth in @users do
      true ->
        [user_id, _] = Base.decode64!(attempted_auth) |> String.split(":")
        assign(conn, :user_id, user_id)
      _ ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_resp_header("www-authenticate", @realm)
    |> send_resp(401, "unauthorized")
    |> halt()
  end
end
