defmodule SparklineSvg.ReferenceLine do
  @moduledoc false

  alias SparklineSvg.ReferenceLine

  @type ref_line_opts :: %{}

  @type t :: %ReferenceLine{
          type: SparklineSvg.ref_line(),
          value: nil | number(),
          options: ref_line_opts()
        }
  @enforce_keys [:type, :value, :options]
  defstruct [:type, :value, :options]

  @valid_types [:max, :min, :avg, :median]
  @default_opts []

  @spec new(SparklineSvg.ref_line()) :: ReferenceLine.t()
  @spec new(SparklineSvg.ref_line(), SparklineSvg.ref_line_options()) :: ReferenceLine.t()
  def new(type, options \\ []) do
    options =
      @default_opts
      |> Keyword.merge(options)
      |> Map.new()

    %ReferenceLine{type: type, value: nil, options: options}
  end

  @spec clean(SparklineSvg.ref_lines()) :: {:ok, SparklineSvg.ref_lines()} | {:error, atom()}
  def clean(ref_lines) do
    keys = Map.keys(ref_lines)

    cond do
      keys == [] -> {:ok, ref_lines}
      Enum.all?(keys, &Enum.member?(@valid_types, &1)) -> {:ok, ref_lines}
      true -> {:error, :invalid_ref_line_type}
    end
  end

  @spec compute(SparklineSvg.ref_lines(), SparklineSvg.points()) :: SparklineSvg.ref_lines()
  def compute(ref_lines, datapoints) do
    ref_lines
    |> Enum.map(fn {type, ref_line} ->
      {type, %ReferenceLine{ref_line | value: do_compute(type, datapoints)}}
    end)
    |> Map.new()
  end

  defp do_compute(:max, _datapoints) do
    # TODO.
    0
  end

  defp do_compute(:min, _datapoints) do
    # TODO.
    0
  end

  defp do_compute(:avg, _datapoints) do
    # TODO.
    0
  end

  defp do_compute(:median, _datapoints) do
    # TODO.
    0
  end
end
