defmodule TellerWeb.AccountControllerTest do
  use TellerWeb.ConnCase

  import Mox

  setup :verify_on_exit!

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012323:"))

    %{conn: conn}
  end

  describe "test GET /accounts" do
    test "GET /accounts sends success response", %{conn: conn} do
      conn = get(conn, "/accounts")

      assert %{
               "accounts" => [
                 %{
                   "currency" => "USD",
                   "enrollment_id" => "enr_YWNjXzQ1Njc4OTAxMjMyMw==",
                   "id" => "acc_456789012323",
                   "institution" => %{
                     "id" => "capital_one",
                     "name" => "Capital One"
                   },
                   "last_four" => "2323",
                   "links" => %{
                     "account" => nil,
                     "balances" => "http://localhost:4000/accounts/acc_456789012323/balances",
                     "details" => "http://localhost:4000/accounts/acc_456789012323/details",
                     "self" => "http://localhost:4000/accounts/acc_456789012323",
                     "transactions" =>
                       "http://localhost:4000/accounts/acc_456789012323/transactions"
                   },
                   "name" => "Donald Trump",
                   "routing_numbers" => %{
                     "ach" => 117_921_176
                   },
                   "subtype" => "checking",
                   "type" => "depository"
                 },
                 %{
                   "currency" => "USD",
                   "enrollment_id" => "enr_YWNjXzQ1Njc4OTAxMjMyNA==",
                   "id" => "acc_456789012324",
                   "institution" => %{
                     "id" => "citibank",
                     "name" => "Citibank"
                   },
                   "last_four" => "2324",
                   "links" => %{
                     "account" => nil,
                     "balances" => "http://localhost:4000/accounts/acc_456789012324/balances",
                     "details" => "http://localhost:4000/accounts/acc_456789012324/details",
                     "self" => "http://localhost:4000/accounts/acc_456789012324",
                     "transactions" =>
                       "http://localhost:4000/accounts/acc_456789012324/transactions"
                   },
                   "name" => "Donald Trump",
                   "routing_numbers" => %{
                     "ach" => 4_920_621
                   },
                   "subtype" => "checking",
                   "type" => "depository"
                 }
               ]
             } == json_response(conn, 200)
    end

    test "GET /accounts sends unauthorized response when token is invalid", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012:"))
        |> get("/accounts")

      assert conn.status == 401
    end
  end

  describe "test GET /accounts/:account_id" do
    test "GET /accounts/:account_id sends success response", %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012323")

      assert %{
               "account" => %{
                 "currency" => "USD",
                 "enrollment_id" => "enr_YWNjXzQ1Njc4OTAxMjMyMw==",
                 "id" => "acc_456789012323",
                 "institution" => %{
                   "id" => "capital_one",
                   "name" => "Capital One"
                 },
                 "last_four" => "2323",
                 "links" => %{
                   "account" => nil,
                   "balances" => "http://localhost:4000/accounts/acc_456789012323/balances",
                   "details" => "http://localhost:4000/accounts/acc_456789012323/details",
                   "self" => "http://localhost:4000/accounts/acc_456789012323",
                   "transactions" =>
                     "http://localhost:4000/accounts/acc_456789012323/transactions"
                 },
                 "name" => "Donald Trump",
                 "routing_numbers" => %{
                   "ach" => 117_921_176
                 },
                 "subtype" => "checking",
                 "type" => "depository"
               }
             } == json_response(conn, 200)
    end

    test "GET /accounts/:account_id sends empty response when account is inaccessible for the token",
         %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012325")
      assert conn.status == 404
    end

    test "GET /accounts/:account_id sends unauthorized response when token is invalid", %{
      conn: conn
    } do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012:"))
        |> get("/accounts/acc_456789012325")

      assert conn.status == 401
    end
  end

  describe "test GET /accounts/:account_id/balances" do
    test "GET /accounts/:account_id/balances sends success response", %{conn: conn} do
      Teller.MockDateAPI
      |> expect(:get_end_date, fn -> ~D[2021-12-25] end)

      conn = get(conn, "/accounts/acc_456789012323/balances")

      assert %{
               "account_balances" => %{
                 "account_id" => "acc_456789012323",
                 "available" => "6317985.95",
                 "ledger" => "6317985.95",
                 "links" => %{
                   "account" => "http://localhost:4000/accounts/acc_456789012323",
                   "balances" => nil,
                   "details" => nil,
                   "self" => "http://localhost:4000/accounts/acc_456789012323/balances",
                   "transactions" => nil
                 }
               }
             } == json_response(conn, 200)
    end

    test "GET /accounts/:account_id/balances sends empty response when account is inaccessible for the token",
         %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012325/balances")
      assert conn.status == 404
    end

    test "GET /accounts/:account_id/balances sends unauthorized response when token is invalid",
         %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012:"))
        |> get("/accounts/acc_456789012325/balances")

      assert conn.status == 401
    end
  end

  describe "test GET /accounts/:account_id/details" do
    test "GET /accounts/:account_id/details sends success response", %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012323/details")

      assert %{
               "account" => %{
                 "account_id" => "acc_456789012323",
                 "account_number" => "456789012323",
                 "links" => %{
                   "account" => "http://localhost:4000/accounts/acc_456789012323",
                   "balances" => nil,
                   "details" => nil,
                   "self" => "http://localhost:4000/accounts/acc_456789012323/details",
                   "transactions" => nil
                 },
                 "routing_numbers" => %{
                   "ach" => "117921176"
                 }
               }
             } == json_response(conn, 200)
    end

    test "GET /accounts/:account_id/details sends empty response when account is inaccessible for the token",
         %{conn: conn} do
      conn = get(conn, "/accounts/acc_456789012325/details")
      assert conn.status == 404
    end

    test "GET /accounts/:account_id/details sends unauthorized response when token is invalid", %{
      conn: conn
    } do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test_456789012:"))
        |> get("/accounts/acc_456789012325/details")

      assert conn.status == 401
    end
  end
end
