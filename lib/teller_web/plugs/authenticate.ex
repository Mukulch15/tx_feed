defmodule TellerWeb.Plugs.Authenticate do
  import Plug.Conn
  @realm "Basic realm=\"Dashboard\""

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
    attempted_auth = Base.decode64!(attempted_auth)

    case String.match?(attempted_auth, ~r/^test_\d{12}:$/u) do
      true ->
        token = String.trim_trailing(attempted_auth, ":")
        conn = assign(conn, :token, token)

        if is_nil(Map.get(conn.private, :plug_session)) do
          conn
        else
          put_session(conn, :token, token)
        end

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
