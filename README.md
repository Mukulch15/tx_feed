# Teller

This application acts as a sandbox for teller bank apis. Aim of the application is to mimick accounts and transaction details
so that developers can test these apis on their interface without the need for any actual bank accounts.
The application gives access to the following apis:
  GET /accounts
  GET /accounts/:account_id
  GET /accounts/:account_id/details
  GET /accounts/:account_id/balances
  GET /accounts/:account_id/transactions
  GET /accounts/:account_id/transactions/:transaction_id

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
In order to start using the apis, you have to use basic auth. Enter the username in the following format:
test_ followed by a 12 digit number. The password must be blank.
The base url is http://localhost:4000
A dashboard is accessible on `/statistics` which gives you the count of api calls for a given token.