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
                 "amount" => "-13814.25",
                 "date" => "2021-09-24",
                 "description" => "Chick-Fil-A",
                 "details" => %{
                   "category" => "dining",
                   "counterparty" => %{"name" => "Chick-Fil-A", "type" => "organization"},
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
                 "running_balance" => "7581280.75",
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
                   "amount" => "-13769.05",
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
                   "running_balance" => "7636469.95",
                   "status" => "posted",
                   "type" => "card_payment"
                 },
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-13780.35",
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
                   "running_balance" => "7622689.60",
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

  describe "GET /accounts/:account_id/transactions/?from_id=<from_id>&count=<count> sends paginated response" do
    test "from_id is the last transaction - we should get two results regardless of count", %{
      conn: conn
    } do
      Teller.MockDateAPI
      |> stub(:get_end_date, fn -> ~D[2021-12-25] end)

      conn =
        get(
          conn,
          "/accounts/acc_456789012323/transactions?from_id=NDU2Nzg5MDEyMzIzLTk3&count=5"
        )

      assert %{
               "transactions" => [
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-13831.20",
                   "date" => "2021-12-24",
                   "description" => "CVS",
                   "details" => %{
                     "category" => "investment",
                     "counterparty" => %{"name" => "CVS", "type" => "organization"},
                     "processing_status" => "complete"
                   },
                   "id" => "NDU2Nzg5MDEyMzIzLTk2",
                   "links" => %{
                     "account" => "http://localhost:4000/accounts/acc_456789012323",
                     "balances" => nil,
                     "details" => nil,
                     "self" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTk2",
                     "transactions" => nil
                   },
                   "running_balance" => "6331828.45",
                   "status" => "posted",
                   "type" => "card_payment"
                 },
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-13842.50",
                   "date" => "2021-12-25",
                   "description" => "Duane Reade",
                   "details" => %{
                     "category" => "loan",
                     "counterparty" => %{"name" => "Duane Reade", "type" => "organization"},
                     "processing_status" => "complete"
                   },
                   "id" => "NDU2Nzg5MDEyMzIzLTk3",
                   "links" => %{
                     "account" => "http://localhost:4000/accounts/acc_456789012323",
                     "balances" => nil,
                     "details" => nil,
                     "self" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTk3",
                     "transactions" => nil
                   },
                   "running_balance" => "6317985.95",
                   "status" => "posted",
                   "type" => "card_payment"
                 }
               ]
             } == json_response(conn, 200)
    end

    test "from_id is the first transaction", %{conn: conn} do
      Teller.MockDateAPI
      |> stub(:get_end_date, fn -> ~D[2021-12-25] end)

      conn =
        get(
          conn,
          "/accounts/acc_456789012323/transactions?from_id=NDU2Nzg5MDEyMzIzLTg=&count=2"
        )

      assert %{
               "transactions" => [
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-13836.85",
                   "date" => "2021-09-26",
                   "description" => "Apple",
                   "details" => %{
                     "category" => "electronics",
                     "counterparty" => %{"name" => "Apple", "type" => "organization"},
                     "processing_status" => "complete"
                   },
                   "id" => "NDU2Nzg5MDEyMzIzLTc=",
                   "links" => %{
                     "account" => "http://localhost:4000/accounts/acc_456789012323",
                     "balances" => nil,
                     "details" => nil,
                     "self" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTc=",
                     "transactions" => nil
                   },
                   "running_balance" => "7553618.35",
                   "status" => "posted",
                   "type" => "card_payment"
                 },
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-13848.15",
                   "date" => "2021-09-27",
                   "description" => "Amazon",
                   "details" => %{
                     "category" => "entertainment",
                     "counterparty" => %{"name" => "Amazon", "type" => "organization"},
                     "processing_status" => "complete"
                   },
                   "id" => "NDU2Nzg5MDEyMzIzLTg=",
                   "links" => %{
                     "account" => "http://localhost:4000/accounts/acc_456789012323",
                     "balances" => nil,
                     "details" => nil,
                     "self" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTg=",
                     "transactions" => nil
                   },
                   "running_balance" => "7539770.20",
                   "status" => "posted",
                   "type" => "card_payment"
                 },
                 %{
                   "account_id" => "acc_456789012323",
                   "amount" => "-13859.45",
                   "date" => "2021-09-28",
                   "description" => "Walmart",
                   "details" => %{
                     "category" => "fuel",
                     "counterparty" => %{"name" => "Walmart", "type" => "organization"},
                     "processing_status" => "complete"
                   },
                   "id" => "NDU2Nzg5MDEyMzIzLTk=",
                   "links" => %{
                     "account" => "http://localhost:4000/accounts/acc_456789012323",
                     "balances" => nil,
                     "details" => nil,
                     "self" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTk=",
                     "transactions" => nil
                   },
                   "running_balance" => "7525910.75",
                   "status" => "posted",
                   "type" => "card_payment"
                 }
               ]
             } == json_response(conn, 200)
    end
  end
end
