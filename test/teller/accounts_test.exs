defmodule Teller.AccountsTest do
  alias Teller.Accounts
  import Mox

  use ExUnit.Case

  setup :verify_on_exit!

  test "get_account/1 displayes correct results" do
    assert %Teller.Schemas.Account{
             currency: "USD",
             enrollment_id: "enr_YWNjXzQ1Njc4OTAxMjMzMg==",
             id: "acc_456789012332",
             institution: %Teller.Schemas.Institution{
               id: "bank_of_america",
               name: "Bank of America"
             },
             last_four: "2332",
             links: %Teller.Schemas.Link{
               account: nil,
               balances: "http://localhost:4000/accounts/acc_456789012332/balances",
               details: "http://localhost:4000/accounts/acc_456789012332/details",
               self: "http://localhost:4000/accounts/acc_456789012332",
               transactions: "http://localhost:4000/accounts/acc_456789012332/transactions"
             },
             name: "My Checking",
             routing_numbers: %Teller.Schemas.Routing{ach: 114_666_560},
             subtype: "checking",
             type: "depository"
           } == Accounts.get_account("acc_456789012332")
  end

  test "get_accounts/1 displayes correct results" do
    assert [
             %Teller.Schemas.Account{
               currency: "USD",
               enrollment_id: "enr_YWNjXzQ1Njc4OTAxMjMzMg==",
               id: "acc_456789012332",
               institution: %Teller.Schemas.Institution{
                 id: "bank_of_america",
                 name: "Bank of America"
               },
               last_four: "2332",
               links: %Teller.Schemas.Link{
                 account: nil,
                 balances: "http://localhost:4000/accounts/acc_456789012332/balances",
                 details: "http://localhost:4000/accounts/acc_456789012332/details",
                 self: "http://localhost:4000/accounts/acc_456789012332",
                 transactions: "http://localhost:4000/accounts/acc_456789012332/transactions"
               },
               name: "My Checking",
               routing_numbers: %Teller.Schemas.Routing{ach: 114_666_560},
               subtype: "checking",
               type: "depository"
             },
             %Teller.Schemas.Account{
               currency: "USD",
               enrollment_id: "enr_YWNjXzQ1Njc4OTAxMjMzMw==",
               id: "acc_456789012333",
               institution: %Teller.Schemas.Institution{
                 id: "capital_one",
                 name: "Capital One"
               },
               last_four: "2333",
               links: %Teller.Schemas.Link{
                 account: nil,
                 balances: "http://localhost:4000/accounts/acc_456789012333/balances",
                 details: "http://localhost:4000/accounts/acc_456789012333/details",
                 self: "http://localhost:4000/accounts/acc_456789012333",
                 transactions: "http://localhost:4000/accounts/acc_456789012333/transactions"
               },
               name: "Ronald Reagan",
               routing_numbers: %Teller.Schemas.Routing{ach: 30_070_911},
               subtype: "checking",
               type: "depository"
             }
           ] == Accounts.get_accounts("test_456789012332")
  end

  test "get_account_balances/1 displays correct results" do
    Teller.MockDateAPI
    |> expect(:get_end_date, fn -> ~D[2021-12-25] end)

    assert %Teller.Schemas.AccountBalances{
             account_id: "acc_456789012332",
             available: Decimal.new("117762737.30"),
             ledger: Decimal.new("117762737.30"),
             links: %Teller.Schemas.Link{
               account: "http://localhost:4000/accounts/acc_456789012332",
               balances: nil,
               details: nil,
               self: "http://localhost:4000/accounts/acc_456789012332/balances",
               transactions: nil
             }
           } ==
             Teller.Accounts.get_account_balances("acc_456789012332")
  end

  test "get_account_details/1 displays correct results" do
    assert %Teller.Schemas.AccountDetails{
             account_id: "acc_456789012332",
             account_number: "456789012332",
             links: %Teller.Schemas.Link{
               account: "http://localhost:4000/accounts/acc_456789012332",
               balances: nil,
               details: nil,
               self: "http://localhost:4000/accounts/acc_456789012332/details",
               transactions: nil
             },
             routing_numbers: %Teller.Schemas.Routing{ach: "114666560"}
           } == Teller.Accounts.get_account_details("acc_456789012332")
  end
end
