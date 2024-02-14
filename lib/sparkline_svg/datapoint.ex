defmodule SparklineSvg.Datapoint do
  @moduledoc false

  alias SparklineSvg.Core
  alias SparklineSvg.Type

  @spec clean(SparklineSvg.datapoints()) ::
          {:ok, Core.points(), SparklineSvg.x()} | {:error, atom()}
  def clean([{_x, _y} | _] = datapoints) do
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

    case datapoints do
      {:error, reason} ->
        {:error, reason}

      datapoints ->
        datapoints =
          datapoints
          |> Enum.uniq_by(fn {x, _} -> x end)
          |> Enum.sort_by(fn {x, _} -> x end)

        {:ok, datapoints, type}
    end
  end

  def clean(datapoints) do
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

    case datapoints do
      {:error, reason} -> {:error, reason}
      datapoints -> {:ok, Enum.reverse(datapoints), :number}
    end
  end
end
