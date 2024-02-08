defmodule Sparkline.Marker do
  @moduledoc false

  alias Sparkline.Marker
  alias Sparkline.Type

  @type marker_opts :: %{}

  @type t :: %Marker{
          position: Sparkline.marker(),
          options: marker_opts
        }
  @enforce_keys [:position, :options]
  defstruct [:position, :options]

  @spec new(Sparkline.marker()) :: Marker.t()
  @spec new(Sparkline.marker(), Sparkline.marker_options()) :: Marker.t()
  def new(position, options \\ []) do
    options =
      []
      |> Keyword.merge(options)
      |> Map.new()

    %Marker{position: position, options: options}
  end

  @spec clean(list(Marker.t()), Sparkline.x()) :: {:ok, list(Marker.t())} | {:error, atom()}
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

  @typedoc false
  @typep min_max :: {number(), number()}

  @spec resize(list(Marker.t()), min_max(), min_max(), Sparkline.opts()) :: Sparkline.marker()
  def resize(markers, {_min_x, _max_x}, {_min_y, _max_y}, _options) do
    markers
  end
end
