defmodule Teller do
  @moduledoc """
    This application acts as a sandbox for teller bank apis. Aim of the application is to mimic accounts and transaction details
    so that developers can test these apis on their interface without the need for any actual bank accounts.
    The application gives access to the following apis:
      * GET /accounts
      * GET /accounts/:account_id
      * GET /accounts/:account_id/details
      * GET /accounts/:account_id/balances
      * GET /accounts/:account_id/transactions
      * GET /accounts/:account_id/transactions/:transaction_id

    To start your Phoenix server:

    * Install dependencies with `mix deps.get`
    * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
    In order to start using the apis, you have to use basic auth. Enter the username in the following format:
    test_ followed by a 12 digit number. The password must be blank.
    The base url is http://localhost:4000.
    A dashboard is accessible on http://localhost:4000/statistics which gives you the count of api calls for a given token.

    Technical specification:
    1. The api is accessed using a token in the following format `test_456789012332`(test_ followed by a 12 digit number).
    2. The 12 digit random number acts as a seed for the account numbers accessible through the given api token.
    3. Example in the above case the accounts with numbers `456789012332` and `456789012333` will be generated and accessible.
    4. The transaction feed is generated for 90 days from the current date and will give you the same data for each token and account id each
      and everytime. Even after app restarts.
    5. Given the requirement, the first result in paginated result will be the transaction before the transaction with id=from_id.
       Hence, if `from_id=x` and `count = 4`. Then first resuilt in api will be `x-1` followed by `x, x+1,x+2,x+3`
    6. The dashboard is powered by live view and phoenix pubsub.
    7. We have unit tests for transactions and account as well as integration tests for the respective controllers and
      live view dashboard. I have mocked the end date in the test cases because we want the balance to remain constant
      in the test cases. If we don't mock the end date then after each passing day the running balance will change resulting
      in failing tests.
  """
end
