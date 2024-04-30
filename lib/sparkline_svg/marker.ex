defmodule SparklineSvg.Marker do
  @moduledoc false

  alias SparklineSvg.Marker
  alias SparklineSvg.Type

  @type t :: %Marker{
          position: SparklineSvg.marker(),
          options: map()
        }
  @enforce_keys [:position, :options]
  defstruct [:position, :options]

  @default_single_opts [
    stroke: "red",
    "stroke-width": 0.25
  ]

  @default_range_opts [
    fill: "rgba(255, 0, 0, 0.1)",
    stroke: "red",
    "stroke-width": 0.25
  ]

  @spec new(SparklineSvg.marker()) :: t()
  @spec new(SparklineSvg.marker(), SparklineSvg.marker_options()) :: t()
  def new(position, options \\ [])

  def new(position, options) when is_tuple(position) do
    options =
      @default_range_opts
      |> Keyword.merge(options)
      |> Map.new()

    %Marker{position: position, options: options}
  end

  def new(position, options) do
    options =
      @default_single_opts
      |> Keyword.merge(options)
      |> Map.new()

    %Marker{position: position, options: options}
  end

  @spec clean(list(t()), SparklineSvg.x()) :: {:ok, list(t())} | {:error, atom()}
  def clean(markers, type) do
    markers =
      Enum.reduce_while(markers, [], fn
        %Marker{position: {x1, x2}} = marker, markers ->
          with {:ok, x1, _type} <- Type.cast_x(x1, type),
               {:ok, x2, _type} <- Type.cast_x(x2, type) do
            {:cont, [%Marker{marker | position: {x1, x2}} | markers]}
          else
            {:error, reason} -> {:halt, {:error, reason}}
          end

        %Marker{position: x} = marker, markers ->
          case Type.cast_x(x, type) do
            {:ok, x, _type} -> {:cont, [%Marker{marker | position: x} | markers]}
            {:error, reason} -> {:halt, {:error, reason}}
          end
      end)

    case markers do
      {:error, reason} -> {:error, reason}
      markers -> {:ok, markers}
    end
  end
end
