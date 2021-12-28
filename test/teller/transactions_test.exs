defmodule Teller.TransactionsTest do
  alias Teller.Transactions
  use ExUnit.Case
  import Mox

  setup do
    Teller.MockDateAPI
    |> stub(:get_end_date, fn -> Date.utc_today() end)

    :ok
  end

  test "get_transaction/1 displays correct results" do
    assert %Teller.Schemas.Transaction{
             account_id: "acc_456789012323",
             amount: "-13769.05",
             date: ~D[2021-09-20],
             description: "Uber Eats",
             details: %Teller.Schemas.TransactionDetails{
               category: "advertising",
               counterparty: %Teller.Schemas.TransactionCounterParty{
                 name: "Uber Eats",
                 type: "organization"
               },
               processing_status: "complete"
             },
             id: "NDU2Nzg5MDEyMzIzLTE=",
             links: %Teller.Schemas.Link{
               account: "http://localhost:4000/accounts/acc_456789012323",
               balances: nil,
               details: nil,
               self:
                 "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTE=",
               transactions: nil
             },
             running_balance: "7636469.95",
             status: "posted",
             type: "card_payment"
           } == Transactions.get_transaction("NDU2Nzg5MDEyMzIzLTE=")
  end

  describe "get_transactions/3 pagination testing" do
    test "get_tansactions/3 paginates data correctly" do
      assert [
               %Teller.Schemas.Transaction{
                 account_id: "acc_456789012323",
                 amount: "-13769.05",
                 date: ~D[2021-09-20],
                 description: "Uber Eats",
                 details: %Teller.Schemas.TransactionDetails{
                   category: "advertising",
                   counterparty: %Teller.Schemas.TransactionCounterParty{
                     name: "Uber Eats",
                     type: "organization"
                   },
                   processing_status: "complete"
                 },
                 id: "NDU2Nzg5MDEyMzIzLTE=",
                 links: %Teller.Schemas.Link{
                   account: "http://localhost:4000/accounts/acc_456789012323",
                   balances: nil,
                   details: nil,
                   self:
                     "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTE=",
                   transactions: nil
                 },
                 running_balance: "7636469.95",
                 status: "posted",
                 type: "card_payment"
               },
               %Teller.Schemas.Transaction{
                 account_id: "acc_456789012323",
                 amount: "-13780.35",
                 date: ~D[2021-09-21],
                 description: "Lyft",
                 details: %Teller.Schemas.TransactionDetails{
                   category: "bar",
                   counterparty: %Teller.Schemas.TransactionCounterParty{
                     name: "Lyft",
                     type: "organization"
                   },
                   processing_status: "complete"
                 },
                 id: "NDU2Nzg5MDEyMzIzLTI=",
                 links: %Teller.Schemas.Link{
                   account: "http://localhost:4000/accounts/acc_456789012323",
                   balances: nil,
                   details: nil,
                   self:
                     "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTI=",
                   transactions: nil
                 },
                 running_balance: "7622689.60",
                 status: "posted",
                 type: "card_payment"
               },
               %Teller.Schemas.Transaction{
                 account_id: "acc_456789012323",
                 amount: "-13791.65",
                 date: ~D[2021-09-22],
                 description: "Five Guys",
                 details: %Teller.Schemas.TransactionDetails{
                   category: "charity",
                   counterparty: %Teller.Schemas.TransactionCounterParty{
                     name: "Five Guys",
                     type: "organization"
                   },
                   processing_status: "complete"
                 },
                 id: "NDU2Nzg5MDEyMzIzLTM=",
                 links: %Teller.Schemas.Link{
                   account: "http://localhost:4000/accounts/acc_456789012323",
                   balances: nil,
                   details: nil,
                   self:
                     "http://localhost:4000/accounts/acc_456789012323/transactions/NDU2Nzg5MDEyMzIzLTM=",
                   transactions: nil
                 },
                 running_balance: "7608897.95",
                 status: "posted",
                 type: "card_payment"
               }
             ] ==
               Teller.Transactions.get_transactions(
                 "acc_456789012323",
                 "NDU2Nzg5MDEyMzIzLTE=",
                 "3"
               )
    end

    test "get_transactions/3 displays empty result if the transaction doesn't belong to the account" do
      assert [] ==
               Teller.Transactions.get_transactions(
                 "acc_456789012324",
                 "NDU2Nzg5MDEyMzIzLTE=",
                 "3"
               )
    end
  end
end
