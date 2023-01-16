defmodule PotentialLiterature.JulianDay do
  def to_julian_day(%DateTime{} = dt) do
    to_julian_day(dt |> DateTime.to_date())
  end

  def to_julian_day(%Date{} = date) do
    {year, _} = Date.year_of_era(date)
    year * 1000 + Date.day_of_year(date)
  end
end
