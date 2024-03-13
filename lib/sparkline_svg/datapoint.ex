defmodule SparklineSvg.Datapoint do
  @moduledoc false

  alias SparklineSvg.Core
  alias SparklineSvg.Type

  @spec clean(SparklineSvg.datapoints(), SparklineSvg.window()) ::
          {:ok, Core.points(), SparklineSvg.window(), SparklineSvg.x()} | {:error, atom()}
  def clean([{_x, _y} | _] = datapoints, window) do
    {datapoints, type} =
      Enum.reduce_while(datapoints, {[], nil}, fn
        {x, y}, {datapoints, type} ->
          with {:ok, x, type} <- Type.cast_x(x, type),
               {:ok, y} <- Type.cast_y(y) do
            {:cont, {[{x, y} | datapoints], type}}
          else
            {:error, reason} -> {:halt, {{:error, reason}, type}}
          end

        _only_y, {_datapoints, type} ->
          {:halt, {{:error, :mixed_datapoints_types}, type}}
      end)

    with datapoints when is_list(datapoints) <- datapoints,
         {:ok, min, _type} <- Type.cast_window(window.min, type),
         {:ok, max, _type} <- Type.cast_window(window.max, type) do
      window = %{min: min, max: max}

      datapoints =
        datapoints
        |> Enum.uniq_by(fn {x, _} -> x end)
        |> Enum.sort_by(fn {x, _} -> x end)
        |> window(window)

      {:ok, datapoints, window, type}
    end
  end

  def clean(datapoints, window) do
    datapoints =
      datapoints
      |> Enum.with_index()
      |> Enum.reduce_while([], fn
        {{_, _}, _index}, _datapoints ->
          {:halt, {:error, :mixed_datapoints_types}}

        {y, index}, datapoints ->
          case Type.cast_y(y) do
            {:ok, y} -> {:cont, [{index, y} | datapoints]}
            {:error, reason} -> {:halt, {:error, reason}}
          end
      end)

    with datapoints when is_list(datapoints) <- datapoints,
         {:ok, min, _type} <- Type.cast_window(window.min, :number),
         {:ok, max, _type} <- Type.cast_window(window.max, :number) do
      window = %{min: min, max: max}

      datapoints =
        datapoints
        |> Enum.reverse()
        |> window(window)

      {:ok, datapoints, window, :number}
    end
  end

  @spec window(Core.points(), SparklineSvg.window()) :: Core.points()
  def window(datapoints, %{min: :auto, max: :auto}) do
    datapoints
  end

  def window(datapoints, %{min: min, max: :auto}) do
    Enum.filter(datapoints, fn {x, _} -> x >= min end)
  end

  def window(datapoints, %{min: :auto, max: max}) do
    Enum.filter(datapoints, fn {x, _} -> x <= max end)
  end

  def window(datapoints, %{min: min, max: max}) do
    Enum.filter(datapoints, fn {x, _} -> x >= min and x <= max end)
  end
end
