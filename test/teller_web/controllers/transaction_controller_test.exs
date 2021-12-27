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
      |> expect(:get_end_date, fn -> Date.utc_today() end)

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

    test "GET /accounts/:account_id/transactions/:transaction_id sends 404 when account is inaccessible for the token",
         %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012321/transactions/NDU2Nzg5MDEyMzIzLTU=")
      assert conn.status == 404
    end

    test "GET /accounts/:account_id/transactions/:transaction_id sends unauthorized response 401 when token is invalid",
         %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012:"))
        |> get("/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTU=")

      assert conn.status == 401
    end

    test "GET /accounts/:account_id/transactions/:transaction_id sends 404 when transaction_id is not found",
         %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzI0LTM=")
      assert conn.status == 404
    end
  end

  describe "test GET /accounts/:account_id/transactions/" do
    test "GET /accounts/:account_id/transactions/ sends success response", %{
      conn: conn
    } do
      Teller.MockDateAPI
      |> stub(:get_end_date, fn -> ~D[2021-09-21] end)

      conn = get(conn, "/accounts/acc_456789012323/transactions")

      assert %{
               "transactions" => [
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-11695.50",
                   "date" => "2021-09-20",
                   "description" => "Uber Eats",
                   "details" => %{
                     "category" => "advertising",
                     "counterparty" => %{"name" => "Uber Eats", "type" => "organization"},
                     "processing_status" => "complete"
                   },
                   "id" => "NDU2Nzg5MDEyMzIzLTE=",
                   "links" => %{
                     "account" => "http://localhost:4000/accounts/acc_456789012323",
                     "balances" => nil,
                     "details" => nil,
                     "self" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTE=",
                     "transactions" => nil
                   },
                   "running_balance" => "7638543.50",
                   "status" => "posted",
                   "type" => "card_payment"
                 },
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-11706.80",
                   "date" => "2021-09-21",
                   "description" => "Lyft",
                   "details" => %{
                     "category" => "bar",
                     "counterparty" => %{"name" => "Lyft", "type" => "organization"},
                     "processing_status" => "complete"
                   },
                   "id" => "NDU2Nzg5MDEyMzIzLTI=",
                   "links" => %{
                     "account" => "http://localhost:4000/accounts/acc_456789012323",
                     "balances" => nil,
                     "details" => nil,
                     "self" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTI=",
                     "transactions" => nil
                   },
                   "running_balance" => "7626836.70",
                   "status" => "posted",
                   "type" => "card_payment"
                 }
               ]
             } == json_response(conn, 200)
    end

    test "GET /accounts/:account_id/transactions/ sends empty response when account is inaccessible for the token",
         %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012321/transactions")
      assert conn.status == 404
    end

    test "GET /accounts/:account_id/transactions/:transaction_id sends unauthorized response when token is invalid",
         %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012:"))
        |> get("/accounts/acc_456789012323/transactions")

      assert conn.status == 401
    end
  end
end
