defmodule TellerWeb.TransactionControllerTest do
  use TellerWeb.ConnCase
  import Mox
  setup :verify_on_exit!


  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012323:"))

    %{conn: conn}
  end

  describe "test GET /accounts/:account_id/transactions/:transaction_id" do
    test "GET /accounts/:account_id/transactions/:transaction_id sends success response", %{
      conn: conn
    } do
      Teller.MockDateAPI
      |> expect(:get_end_date, fn ->Date.utc_today() end)
      conn = get(conn, "/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTU=")

      assert %{
               "transaction" => %{
                 "account_id" => "acc_456789012323",
                 "amount" => "-11740.70",
                 "date" => "2021-09-24",
                 "description" => "Chick-Fil-A",
                 "details" => %{
                   "category" => "advertising",
                   "counterparty" => %{
                     "name" => "Chick-Fil-A",
                     "type" => "organization"
                   },
                   "processing_status" => "complete"
                 },
                 "id" => "NDU2Nzg5MDEyMzIzLTU=",
                 "links" => %{
                   "account" => "http://localhost:4000/accounts/acc_456789012323",
                   "balances" => nil,
                   "details" => nil,
                   "self" =>
                     "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTU=",
                   "transactions" => nil
                 },
                 "running_balance" => "7591648.50",
                 "status" => "posted",
                 "type" => "card_payment"
               }
             } == json_response(conn, 200)
    end

    test "GET /accounts/:account_id/transactions/:transaction_id sends empty response when account is inaccessible for the token",
         %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012321/transactions/NDU2Nzg5MDEyMzIzLTU=")
      assert conn.status == 404
    end

    test "GET /accounts/:account_id/transactions/:transaction_id sends unauthorized response when token is invalid",
         %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012:"))
        |> get("/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTU=")

      assert conn.status == 401
    end
  end
end
