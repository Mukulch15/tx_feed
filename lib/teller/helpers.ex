defmodule Teller.Helpers do
  @moduledoc """
    Consists of auxillary functions to help generate the feed.
  """
  @start_date ~D[2021-09-19]

  @doc """
    Gives the sum for a list consisting of tuples.
    Example [{"a", #Decimal<1.0>}, {"a", #Decimal<3.0>} ] will output #Decimal<4.0>
  """
  def get_sum(lst) do
    Enum.reduce(lst, Decimal.new(0), fn {_, x}, acc -> Decimal.add(x, acc) end)
  end

  @doc """
    This function generates the datewise transaction values and a running balance based on total transaction value
    and opening balance. The function also takes a salt which is basically the hash of the account_id within a range
    of 0..400. This is done to make the amount of each transaction different for each account.
    Example for the following call Teller.Helpers.calculate_date_amounts(Decimal.new(77474), 7) output will be:
    `{[
      {~D[2021-09-20], #Decimal<-11735.05>},
      {~D[2021-09-21], #Decimal<-11746.35>},
      {~D[2021-09-22], #Decimal<-11757.65>},
      {~D[2021-09-23], #Decimal<-11768.95>},
      {~D[2021-09-24], #Decimal<-11780.25>},
      {~D[2021-09-25], #Decimal<-11791.55>},
      {~D[2021-09-26], #Decimal<-6894.20>}
    ], #Decimal<-6894.20>}`
  """
  def calculate_date_amounts(opening_balance, salt) do
    diff = get_diff()

    Enum.reduce_while(1..diff, {[], Decimal.new(opening_balance)}, fn y, acc ->
      {lst, available} = acc
      d = Date.add(@start_date, y)
      {_, _, q} = Date.to_erl(d)

      m =
        d
        |> Date.to_string()
        |> String.split("-")
        |> Enum.map(fn x -> String.to_integer(x) end)
        |> Enum.sum()
        |> Decimal.new()
        |> Decimal.add(q)
        |> Decimal.add(salt)
        |> Decimal.mult(Decimal.from_float(5.65))
        |> Decimal.negate()

      if Decimal.compare(Decimal.add(available, m), Decimal.from_float(0.0)) == :gt do
        {:cont, {lst ++ [{d, m}], Decimal.add(available, m)}}
      else
        {:halt, {lst ++ [{d, Decimal.negate(available)}], Decimal.negate(available)}}
      end
    end)
  end

  def paginate_transactions([f, s], count) when length(f) == 1 do
    case count do
      "0" ->
        []

      "1" ->
        f

      nil ->
        f ++ s

      n ->
        f ++ Enum.take(s, String.to_integer(n) - 1)
    end
  end

  def paginate_transactions([f, s], count) when length(s) == 1 do
    [h | _] = :lists.reverse(f)

    case count do
      "0" ->
        []

      _ ->
        [h] ++ s
    end
  end

  def paginate_transactions([f, s, t], count) do
    [h | _] = :lists.reverse(f)

    case count do
      "1" ->
        [h] ++ s

      "0" ->
        [h]

      nil ->
        [h] ++ s ++ t

      n ->
        [h] ++ s ++ Enum.take(t, String.to_integer(n) - 1)
    end
  end

  def paginate_transactions(_, _) do
    []
  end

  def get_diff() do
    end_date = get_end_date()
    # end_date = ~D[2022-01-01]
    Date.diff(end_date, @start_date)
  end

  def get_salt(val) do
    :erlang.phash2(val, 400)
  end

  defp date_api_client, do: Application.get_env(:teller, :date_api_client)
  defp get_end_date, do: date_api_client().get_end_date
end
