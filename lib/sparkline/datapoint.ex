defmodule Sparkline.Datapoint do
  @moduledoc false

  @type point :: %{x: number(), y: number()}
  @type points :: list(point())
  @type min_max :: {number(), number()}

  @spec clean(Sparkline.datapoints()) :: {:ok, Sparkline.datapoints()} | {:error, atom()}
  def clean(datapoints) do
    {datapoints, _type} =
      Enum.reduce_while(datapoints, {[], nil}, fn {x, y}, {datapoints, type} ->
        with {:ok, x, type} <- clean_x(x, type),
             {:ok, y} <- clean_y(y) do
          {:cont, {[{x, y} | datapoints], type}}
        else
          {:error, reason} -> {:halt, {{:error, reason}, type}}
        end
      end)

    case datapoints do
      {:error, reason} ->
        {:error, reason}

      datapoints ->
        datapoints =
          datapoints
          |> Enum.uniq_by(fn {x, _} -> x end)
          |> Enum.sort_by(fn {x, _} -> x end)

        {:ok, datapoints}
    end
  end

  @spec clean_x(DateTime.t() | Date.t() | Time.t() | number(), atom()) ::
          {:ok, number(), atom()} | {:error, atom()}
  defp clean_x(x, nil) when is_number(x) do
    clean_x(x, :number)
  end

  defp clean_x(%module{} = x, nil) when is_struct(x) do
    clean_x(x, module)
  end

  defp clean_x(%DateTime{} = datetime, DateTime) do
    {:ok, DateTime.to_unix(datetime), DateTime}
  end

  defp clean_x(%Date{} = date, Date) do
    {:ok, datetime} = DateTime.new(date, ~T[00:00:00])
    {:ok, DateTime.to_unix(datetime), Date}
  end

  defp clean_x(%Time{} = time, Time) do
    {seconds, _milliseconds} = Time.to_seconds_after_midnight(time)
    {:ok, seconds, Time}
  end

  defp clean_x(x, :number) when is_number(x) do
    {:ok, x, :number}
  end

  defp clean_x(x, _type) when is_number(x) or x.__struct__ in [DateTime, Date, Time] do
    {:error, :mixed_datapoints_types}
  end

  defp clean_x(_x, _type) do
    {:error, :invalid_x_type}
  end

  @spec clean_y(number()) :: {:ok, number()} | {:error, atom()}
  defp clean_y(y) when is_number(y) do
    {:ok, y}
  end

  defp clean_y(_y) do
    {:error, :invalid_y_type}
  end

  @spec get_min_max(Sparkline.datapoints()) :: {min_max(), min_max()}
  def get_min_max(datapoints) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(datapoints, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(datapoints, fn {_, y} -> y end)
    [{x, y} | _tail] = datapoints

    min_max_x = if max_x - min_x == 0, do: {0, 2 * x}, else: {min_x, max_x}

    min_max_y =
      cond do
        max_y - min_y != 0 -> {min_y, max_y}
        y == 0 -> {-1, 1}
        true -> {0, 2 * y}
      end

    {min_max_x, min_max_y}
  end

  @spec resize(Sparkline.datapoints(), min_max(), min_max(), Sparkline.map_options()) :: points()
  def resize(datapoints, {min_x, max_x}, {min_y, max_y}, options) do
    width = options.width
    height = options.height
    padding = options.padding

    Enum.map(datapoints, fn {x, y} ->
      %{
        x: (x - min_x) / (max_x - min_x) * (width - padding * 2) + padding,
        y: height - (y - min_y) / (max_y - min_y) * (height - padding * 2) - padding
      }
    end)
  end
end
