defmodule Teller.Behaviours.DateAPI do
  @callback get_end_date() :: Date.t()
end
