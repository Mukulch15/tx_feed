defmodule Test do
  @start_date ~D[2021-09-19]

  def calc() do
    diff = get_diff()

    Enum.map(1..diff, fn y ->
      # start = Date.new!(2022, 1,1)
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

      {d, m}
    end)
  end

  def get_diff() do
    # end_date = Date.utc_today()
    end_date = ~D[2022-01-01]
    Date.diff(end_date, @start_date)
  end
end
