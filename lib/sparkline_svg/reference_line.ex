defmodule SparklineSvg.ReferenceLine do
  @moduledoc """
  `m:SparklineSvg.ReferenceLine` is an internal struct used by `m:SparklineSvg` to represent a
  reference line.

  There are five types of reference lines; four of them are easily accessible by using the
  corresponding atom:

  - `:max` - shows the maximum value of the chart.
  - `:min` - shows the minimum value of the chart.
  - `:avg` - shows the average value of the chart.
  - `:median` - shows the median value of the chart.

  ``` elixir
  # Use a predefined reference line
  sparkline =
    [1, 2, 3, 1]
    |> SparklineSvg.new()
    |> SparklineSvg.show_line()
    |> SparklineSvg.show_ref_line(:max)
  ```

  The fifth type is a percentile reference line, which can be created by calling `percentile/1` as
  the second argument of `SparklineSvg.show_ref_line/3`.

  ``` elixir
  # Use the percentile reference line with custom options
  percentile_99 = SparklineSvg.ReferenceLine.percentile(99)

  sparkline =
    [1, 2, 3, 1]
    |> SparklineSvg.new()
    |> SparklineSvg.show_line()
    |> SparklineSvg.show_ref_line(percentile_99)
  ```

  Finally, you can implement custom reference lines by passing a function that receives
  `t:SparklineSvg.Core.points/0` and returns a unique `t:SparklineSvg.Core.y/0` value at which to
  display the line.

  ``` elixir
  # Use a custom reference line
  fixed_ref_line = fn _ -> 7 end

  custom_ref_line =
    fn points ->
      Enum.sum_by(points, fn {_x, y} -> y end) / 3
    end

  sparkline =
    [1, 2, 3, 1]
    |> SparklineSvg.new()
    |> SparklineSvg.show_line()
    |> SparklineSvg.show_ref_line(fixed_ref_line, color: "blue")
    |> SparklineSvg.show_ref_line(custom_ref_line, color: "red")
  ```

  Note that the custom function for a reference line will be called after the main checks and
  transformations of the data points. No further checks are performed on the returned value.
  """

  alias SparklineSvg.Core
  alias SparklineSvg.ReferenceLine

  @typedoc "A reference line function."
  @type ref_line_function :: (Core.points() -> Core.y())

  @typedoc false
  @type ref_line_opts :: %{
          width: String.t(),
          color: String.t(),
          dasharray: String.t(),
          class: nil | String.t()
        }

  @typedoc false
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

  @doc false
  @spec new(SparklineSvg.ref_line()) :: ReferenceLine.t()
  @spec new(SparklineSvg.ref_line(), SparklineSvg.ref_line_options()) :: ReferenceLine.t()
  def new(type, options \\ []) do
    options =
      @default_opts
      |> Keyword.merge(options)
      |> Map.new()

    %ReferenceLine{type: type, value: nil, position: nil, options: options}
  end

  @doc false
  @spec clean(SparklineSvg.ref_lines()) :: {:ok, SparklineSvg.ref_lines()} | {:error, atom()}
  def clean(ref_lines) do
    keys = Map.keys(ref_lines)

    cond do
      keys == [] -> {:ok, ref_lines}
      Enum.all?(keys, &valid_type?/1) -> {:ok, ref_lines}
      true -> {:error, :invalid_ref_line_type}
    end
  end

  @doc """
  A function that returns the maximum value of a list of points.

  ## Examples

      iex> max_function = SparklineSvg.ReferenceLine.max()
      iex> max_function.([{1, 1}, {2, 2}, {3, 3}, {4, 1}])
      3

  """

  @doc since: "0.4.0"
  @spec max() :: ref_line_function()
  def max do
    fn datapoints ->
      {_x, y} = Enum.max_by(datapoints, fn {_x, y} -> y end)
      y
    end
  end

  @doc """
  A function that returns the minimum value of a list of points.

  ## Examples

      iex> min_function = SparklineSvg.ReferenceLine.min()
      iex> min_function.([{1, 1}, {2, 2}, {3, 3}, {4, 1}])
      1

  """

  @doc since: "0.4.0"
  @spec min() :: ref_line_function()
  def min do
    fn datapoints ->
      {_x, y} = Enum.min_by(datapoints, fn {_x, y} -> y end)
      y
    end
  end

  @doc """
  A function that returns the average value of a list of points.

  ## Examples

      iex> avg_function = SparklineSvg.ReferenceLine.avg()
      iex> avg_function.([{1, 1}, {2, 2}, {3, 3}, {4, 1}])
      1.75

  """

  @doc since: "0.4.0"
  @spec avg() :: ref_line_function()
  def avg do
    fn datapoints ->
      {sum, count} =
        Enum.reduce(datapoints, {0, 0}, fn {_x, y}, {sum, count} -> {sum + y, count + 1} end)

      sum / count
    end
  end

  @doc """
  A function that returns the median value of a list of points.

  ## Examples

      iex> median_function = SparklineSvg.ReferenceLine.median()
      iex> median_function.([{1, 1}, {2, 2}, {3, 3}, {4, 1}])
      1.5

  """

  @doc since: "0.4.0"
  @spec median() :: ref_line_function()
  def median do
    fn datapoints ->
      sorted_value = Enum.map(datapoints, &elem(&1, 1)) |> Enum.sort()
      length = Enum.count(sorted_value)
      mid = div(length, 2)

      if rem(length, 2) == 0 do
        case Enum.drop(sorted_value, mid - 1) do
          [a, b | _] -> (a + b) / 2
          [a] -> a
        end
      else
        Enum.at(sorted_value, mid)
      end
    end
  end

  @doc """
  A function that returns, given a `integer()` `nth`, the `nth` percentile value of a list of
  points.

  ## Examples

      iex> percentile_99 = SparklineSvg.ReferenceLine.percentile(99)
      iex> percentile_99.([{1, 1}, {2, 2}, {3, 3}, {4, 1}])
      3

  """

  @doc since: "0.4.0"
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
