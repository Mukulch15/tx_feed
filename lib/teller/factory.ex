defmodule Teller.Factory do
  @moduledoc false
  def merchants do
    ["Uber", "Uber Eats", "Lyft", "Five Guys", "In-N-Out Burger", "Chick-Fil-A"]
  end

  def categories do
    [
      "accommodation",
      "advertising",
      "bar",
      "charity"
    ]
  end

  def institutions do
    ["Chase", "Bank of America", "Wells Fargo", "Citibank", "Capital One"]
  end

  def account_names do
    [
      "My Checking",
      "Jimmy Carter",
      "Ronald Reagan",
      "George H. W. Bush",
      "Bill Clinton",
      "George W. Bush",
      "Barack Obama",
      "Donald Trump"
    ]
  end
end
