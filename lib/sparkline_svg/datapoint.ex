defmodule SparklineSvg.Datapoint do
  @moduledoc false

  alias SparklineSvg.Type

  @typedoc false
  @type point :: %{x: number(), y: number()}

  @typedoc false
  @type points :: list(point())

  @spec clean(SparklineSvg.datapoints()) ::
          {:ok, SparklineSvg.datapoints(), SparklineSvg.x()} | {:error, atom()}
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

  @typedoc false
  @typep min_max :: {number(), number()}

  @spec get_min_max(SparklineSvg.datapoints()) :: {min_max(), min_max()}
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

  @spec resize(SparklineSvg.datapoints(), min_max(), min_max(), SparklineSvg.opts()) :: points()
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
