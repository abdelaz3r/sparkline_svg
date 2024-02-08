defmodule Sparkline.Type do
  @moduledoc false

  @spec cast_x(Sparkline.x(), atom()) :: {:ok, number(), atom()} | {:error, atom()}
  def cast_x(x, nil) when is_number(x), do: cast_x(x, :number)
  def cast_x(%module{} = x, nil) when is_struct(x), do: cast_x(x, module)

  def cast_x(%DateTime{} = datetime, DateTime) do
    {:ok, DateTime.to_unix(datetime), DateTime}
  end

  def cast_x(%Date{} = date, Date) do
    {:ok, datetime} = DateTime.new(date, ~T[00:00:00])
    {:ok, DateTime.to_unix(datetime), Date}
  end

  def cast_x(%Time{} = time, Time) do
    {seconds, _milliseconds} = Time.to_seconds_after_midnight(time)
    {:ok, seconds, Time}
  end

  def cast_x(%NaiveDateTime{} = datetime, NaiveDateTime) do
    {seconds, _} = NaiveDateTime.to_gregorian_seconds(datetime)
    {:ok, seconds, NaiveDateTime}
  end

  def cast_x(x, :number) when is_number(x) do
    {:ok, x, :number}
  end

  def cast_x(x, _type)
      when is_number(x) or x.__struct__ in [NaiveDateTime, DateTime, Date, Time] do
    {:error, :mixed_datapoints_types}
  end

  def cast_x(_x, _type) do
    {:error, :invalid_x_type}
  end

  @spec cast_y(Sparkline.y()) :: {:ok, Sparkline.y()} | {:error, atom()}
  def cast_y(y) when is_number(y) do
    {:ok, y}
  end

  def cast_y(_y) do
    {:error, :invalid_y_type}
  end
end
