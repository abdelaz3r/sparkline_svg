defmodule SparklineSvg.ReferenceLine do
  @moduledoc false

  alias SparklineSvg.ReferenceLine

  @type reference_line_opts :: %{}

  @type t :: %ReferenceLine{
          type: SparklineSvg.reference_line(),
          options: reference_line_opts()
        }
  @enforce_keys [:type, :options]
  defstruct [:type, :options]

  @default_opts [
    type: :avg
  ]

  @spec new() :: ReferenceLine.t()
  @spec new(SparklineSvg.reference_line_options()) :: ReferenceLine.t()
  def new(options \\ []) do
    options =
      @default_opts
      |> Keyword.merge(options)
      |> Map.new()

    %ReferenceLine{type: options.type, options: Map.delete(options, :type)}
  end
end
