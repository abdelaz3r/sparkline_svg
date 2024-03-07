defmodule SparklineSvg.ReferenceLine do
  @moduledoc false

  alias SparklineSvg.Core
  alias SparklineSvg.ReferenceLine

  @type ref_line_function :: (Core.points() -> Core.y())

  @type ref_line_opts :: %{
          width: String.t(),
          color: String.t(),
          dasharray: String.t(),
          class: nil | String.t()
        }

  @type t :: %ReferenceLine{
          type: SparklineSvg.ref_line(),
          value: nil | number(),
          position: nil | number(),
          options: ref_line_opts()
        }
  @enforce_keys [:type, :value, :position, :options]
  defstruct [:type, :value, :position, :options]

  @valid_types [:max, :min, :avg, :median]
  @default_opts [width: 0.25, color: "rgba(0, 0, 0, 0.5)", dasharray: "", class: nil]

  @spec new(SparklineSvg.ref_line()) :: ReferenceLine.t()
  @spec new(SparklineSvg.ref_line(), SparklineSvg.ref_line_options()) :: ReferenceLine.t()
  def new(type, options \\ []) do
    options =
      @default_opts
      |> Keyword.merge(options)
      |> Map.new()

    %ReferenceLine{type: type, value: nil, position: nil, options: options}
  end

  @spec clean(SparklineSvg.ref_lines()) :: {:ok, SparklineSvg.ref_lines()} | {:error, atom()}
  def clean(ref_lines) do
    keys = Map.keys(ref_lines)

    cond do
      keys == [] -> {:ok, ref_lines}
      Enum.all?(keys, &valid_type?/1) -> {:ok, ref_lines}
      true -> {:error, :invalid_ref_line_type}
    end
  end

  @spec max() :: ref_line_function()
  def max do
    fn datapoints ->
      {_x, y} = Enum.max_by(datapoints, fn {_x, y} -> y end)
      y
    end
  end

  @spec min() :: ref_line_function()
  def min do
    fn datapoints ->
      {_x, y} = Enum.min_by(datapoints, fn {_x, y} -> y end)
      y
    end
  end

  @spec avg() :: ref_line_function()
  def avg do
    fn datapoints ->
      {sum, count} =
        Enum.reduce(datapoints, {0, 0}, fn {_x, y}, {sum, count} -> {sum + y, count + 1} end)

      sum / count
    end
  end

  @spec median() :: ref_line_function()
  def median do
    fn datapoints ->
      sorted_datapoints = Enum.sort_by(datapoints, fn {_x, y} -> y end)
      length = Enum.count(sorted_datapoints)
      mid = div(length, 2)

      if rem(length, 2) == 0 do
        {_x, left} = Enum.at(sorted_datapoints, mid - 1)
        {_x, right} = Enum.at(sorted_datapoints, mid)

        (left + right) / 2
      else
        {_x, y} = Enum.at(sorted_datapoints, mid)
        y
      end
    end
  end

  @spec percentile(integer()) :: ref_line_function()
  def percentile(nth) do
    fn datapoints ->
      values_count = length(datapoints)

      case nth / 100 * (values_count + 1) do
        n when n < 1 ->
          0

        n ->
          sorted_values = Enum.map(datapoints, &elem(&1, 1)) |> Enum.sort()

          case Enum.drop(sorted_values, max(0, trunc(n) - 1)) do
            [a, b | _] -> a + (n - trunc(n)) * (b - a)
            [a] -> a
          end
      end
    end
  end

  @spec valid_type?(SparklineSvg.ref_line()) :: boolean()
  defp valid_type?(type) when type in @valid_types, do: true
  defp valid_type?(fun) when is_function(fun, 1), do: true
  defp valid_type?(_), do: false
end
