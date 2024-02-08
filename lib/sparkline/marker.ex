defmodule Sparkline.Marker do
  @moduledoc false

  alias Sparkline.Marker

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
  def clean(markers, _type) do
    {:ok, markers}
  end

  @typedoc false
  @typep min_max :: {number(), number()}

  @spec resize(list(Marker.t()), min_max(), min_max(), Sparkline.opts()) :: Sparkline.marker()
  def resize(markers, {_min_x, _max_x}, {_min_y, _max_y}, _options) do
    markers
  end
end
