defmodule LiveView.StatisticsTest do
  import Plug.Conn

  import Phoenix.LiveViewTest
  use TellerWeb.ConnCase

  test "connected mount", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/dashboard")
    IO.inspect(html)
    assert html =~ "<h1>My Connected View</h1>"
  end
end
