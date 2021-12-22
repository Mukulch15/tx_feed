defmodule Teller.Factory do

  @merchants ["Uber", "Uber Eats", "Lyft", "Five Guys", "In-N-Out Burger", "Chick-Fil-A"]

  @categories [
    "accommodation",
    "advertising",
    "bar",
    "charity"
  ]
  @institutions ["Chase", "Bank of America", "Wells Fargo", "Citibank", "Capital One"]

  @accounts %{
    "acc_12345678900" => {"My Checking", Decimal.from_float(128_123.12)},
    "acc_12345678901" => {"Jimmy Carter", Decimal.from_float(129_124.34)},
    "acc_12345678902" => {"Ronald Reagan", Decimal.from_float(1_410_125.45)},
    "acc_12345678903" => {"George H. W. Bush", Decimal.from_float(1_511_126.67)},
    "acc_12345678904" => {"Bill Clinton", Decimal.from_float(1_612_127.87)},
    "acc_12345678905" => {"George W. Bush", Decimal.from_float(1_713_128.93)},
    "acc_12345678906" => {"Barack Obama", Decimal.from_float(1_814_129.65)},
    "acc_12345678907" => {"Donald Trump", Decimal.from_float(1_915_130.88)}
  }


  @amounts Test.calc()

  def merchants_data do
    @merchants
  end

  def categories_data do
    @categories
  end

  def institutions_data do
    @institutions
  end
  def accounts_data do
    @accounts
  end

  def amounts_data do
    @amounts
  end
end
