defmodule Teller.Helpers do
  @start_date ~D[2021-09-19]

  def get_sum(lst) do
    Enum.reduce(lst, Decimal.new(0), fn {_, x}, acc -> Decimal.add(x, acc) end)
  end

  def calculate_date_amounts(opening_balance) do
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
        |> Decimal.mult(Decimal.from_float(5.65))
        |> Decimal.negate()

      if Decimal.compare(Decimal.add(available, m), Decimal.from_float(0.0)) == :gt do
        {:cont, {lst ++ [{d, m}], Decimal.add(available, m)}}
      else
        {:halt, {lst ++ [{d, Decimal.negate(available)}]}, Decimal.negate(available)}
      end
    end)
  end

  def calculate_date_amounts() do
    :observer_backend
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
    end_date = Date.utc_today()

    # end_date = ~D[2022-01-01]
    Date.diff(end_date, @start_date)
  end
end
