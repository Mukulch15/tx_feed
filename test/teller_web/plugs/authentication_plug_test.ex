defmodule TellerWeb.Plugs.AutheticationPlugTest do
  use TellerWeb.ConnCase

  test "conn is authenticated when the credentials are absent" do
    conn =
      build_conn()
      |> TellerWeb.Plugs.Authenticate.call(%{})

    assert conn.status == 401
  end

  test "conn is unauthenticated when the credentials are wrong" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_45678901232:"))
      |> TellerWeb.Plugs.Authenticate.call(%{})

    assert conn.status == 401
  end

  test "conn is authenticated when the credentials are right" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012323:"))
      |> TellerWeb.Plugs.Authenticate.call(%{})

    assert conn.assigns.token == "test_456789012323"
  end
end
