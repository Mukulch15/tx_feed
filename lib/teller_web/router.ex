defmodule TellerWeb.Router do
  use TellerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TellerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TellerWeb.Plugs.Authenticate
  end

  pipeline :auth_api do
    plug :accepts, ["json"]
    plug TellerWeb.Plugs.Authenticate

    plug TellerWeb.Plugs.Authorise
  end

  scope "/", TellerWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  scope "/", TellerWeb do
    pipe_through :auth_api

    get "/accounts", AccountController, :index
    get "/accounts/:account_id", AccountController, :show
    get "/accounts/:account_id/balances", AccountController, :get_account_balances
    get "/accounts/:account_id/details", AccountController, :get_account_details
    get "/accounts/:account_id/transactions", TransactionController, :get_transactions

    get "/accounts/:account_id/transactions/:transaction_id",
        TransactionController,
        :get_transaction
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    # import Phoenix.LiveDashboard.Router

    scope "/", TellerWeb do
      pipe_through :browser
      live "/statistics", Live.Statistics

      # live_dashboard "/dashboard", metrics: TellerWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
