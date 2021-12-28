defmodule Teller.Behaviours.DateAPI do
  @moduledoc """
    Behaviour for the date_api client
  """
  @callback get_end_date() :: Date.t()
end
