defmodule TellerWeb.Plugs.AuthorizationPlugTest do
  use TellerWeb.ConnCase

  test "404 when account_id is not found" do
    conn =
      build_conn(:get, "/accounts", %{"account_id" => "acc_45678901232"})
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012323:"))
      |> TellerWeb.Plugs.Authenticate.call(%{})
      |> TellerWeb.Plugs.Authorise.call(%{})

    assert conn.status == 404
  end

  test "404 when transaction is not found" do
    conn =
      build_conn(:get, "/accounts/:account_id/transactions/:transaction_id", %{
        "account_id" => "acc_456789012323",
        "transaction_id" => "a"
      })
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012323:"))
      |> TellerWeb.Plugs.Authenticate.call(%{})
      |> TellerWeb.Plugs.Authorise.call(%{})

    assert conn.status == 404
  end

  test "success when account_id is correct" do
    conn =
      build_conn(:get, "/accounts", %{"account_id" => "acc_456789012323"})
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012323:"))
      |> TellerWeb.Plugs.Authenticate.call(%{})
      |> TellerWeb.Plugs.Authorise.call(%{})

    assert conn.status == nil
  end

  test "success when transaction is correct" do
    conn =
      build_conn(:get, "/accounts/:account_id/transactions/:transaction_id", %{
        "account_id" => "acc_456789012323",
        "transaction_id" => "NDU2Nzg5MDEyMzIzLTEx"
      })
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012323:"))
      |> TellerWeb.Plugs.Authenticate.call(%{})
      |> TellerWeb.Plugs.Authorise.call(%{})

    assert conn.status == nil
  end
end
