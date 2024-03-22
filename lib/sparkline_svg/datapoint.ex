defmodule SparklineSvg.Datapoint do
  @moduledoc false

  alias SparklineSvg.Core
  alias SparklineSvg.Type

  @spec clean(SparklineSvg.datapoints(), SparklineSvg.window()) ::
          {:ok, Core.points(), SparklineSvg.window(), SparklineSvg.x()} | {:error, atom()}
  def clean(datapoints, window) do
    {datapoints, type} = ensure_datapoint_type(datapoints)

    with datapoints when is_list(datapoints) <- datapoints,
         {:ok, min} <- Type.cast_window(window.min, type),
         {:ok, max} <- Type.cast_window(window.max, type) do
      window = %{min: min, max: max}

      datapoints =
        datapoints
        |> maybe_window(window)
        |> Enum.uniq_by(fn {x, _} -> x end)
        |> Enum.reverse()

      {:ok, datapoints, window, type}
    end
  end

  @spec ensure_datapoint_type(SparklineSvg.datapoints()) ::
          {Core.points(), SparklineSvg.x()} | {{:error, atom()}, SparklineSvg.x()}
  defp ensure_datapoint_type([{_x, _y} | _] = datapoints) do
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
  end

  defp ensure_datapoint_type(datapoints) do
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

    {datapoints, :number}
  end

  @spec maybe_window(Core.points(), SparklineSvg.window()) :: Core.points()
  def maybe_window(datapoints, %{min: :auto, max: :auto}) do
    datapoints
  end

  def maybe_window(datapoints, %{min: min, max: :auto}) do
    Enum.filter(datapoints, fn {x, _} -> x >= min end)
  end

  def maybe_window(datapoints, %{min: :auto, max: max}) do
    Enum.filter(datapoints, fn {x, _} -> x <= max end)
  end

  def maybe_window(datapoints, %{min: min, max: max}) do
    Enum.filter(datapoints, fn {x, _} -> x >= min and x <= max end)
  end
end
