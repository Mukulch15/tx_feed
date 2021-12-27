defmodule TellerWeb.Live.StatisticsTest do
  import Plug.Conn
  use TellerWeb.ConnCase
  import Phoenix.LiveViewTest

  test "api count increments when an api call is made", %{conn: conn} do
    conn = put_req_header(conn, "authorization", "Basic " <> Base.encode64("test_456789012323:"))
    {:ok, view, _html} = live(conn, "/statistics")
    assert render(view) =~ "<b>Token:</b> test_456789012323"
    assert render(view) =~ "<b>Api count:</b> 0"

    conn
    |> get("/accounts")
    |> get("/accounts")

    assert render(view) =~ "<b>Api count:</b> 2"
  end

  test "get 401 status when api token is incorrect", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_45678901232"))
      |> get("/statistics")

    assert conn.status == 401
  end

  test "get 401 status when api token is absent", %{conn: conn} do
    conn =
      conn
      |> get("/statistics")

    assert conn.status == 401
  end
end
