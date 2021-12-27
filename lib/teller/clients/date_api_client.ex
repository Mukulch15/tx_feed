defmodule Teller.Clients.DateApiClient do
  @moduledoc false
  @behaviour Teller.Behaviours.DateAPI
  @impl true
  def get_end_date() do
    # ~D[2021-12-25]
    Date.utc_today()
  end
end
