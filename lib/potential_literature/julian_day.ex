defmodule PotentialLiterature.JulianDay do
  def to_julian_day(date_or_datetime) do
    date =
      case date_or_datetime do
        %Date{} = date -> date
        %DateTime{} = dt -> dt |> DateTime.to_date()
      end

    {year, _} = Date.year_of_era(date)
    year * 1000 + Date.day_of_year(date)
  end
end
