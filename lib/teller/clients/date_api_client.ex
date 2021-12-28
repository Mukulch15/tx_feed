defmodule Teller.Clients.DateApiClient do
  @moduledoc """
    Api client that fetched the end date for the transaction feed.
  """
  @behaviour Teller.Behaviours.DateAPI
  @impl true
  def get_end_date() do
    # ~D[2021-12-25]
    Date.utc_today()
  end
end
