defmodule Sparkline.Marker do
  @moduledoc false

  alias Sparkline.Marker
  alias Sparkline.Type

  @type marker_opts :: %{
          fill_color: String.t(),
          stroke_color: String.t(),
          stroke_width: String.t(),
          class: nil | String.t()
        }

  @type t :: %Marker{
          position: Sparkline.marker(),
          options: marker_opts()
        }
  @enforce_keys [:position, :options]
  defstruct [:position, :options]

  @spec new(Sparkline.marker()) :: Marker.t()
  @spec new(Sparkline.marker(), Sparkline.marker_options()) :: Marker.t()
  def new(position, options \\ []) do
    options =
      [fill_color: "rgba(255, 0, 0, 0.2)", stroke_color: "red", stroke_width: 0.25, class: nil]
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

  @spec resize(list(Marker.t()), min_max(), Sparkline.opts()) :: list(Marker.t())
  def resize(markers, min_max_x, options) do
    Enum.map(markers, fn marker ->
      case marker.position do
        {x1, x2} ->
          x1 = resize_x(x1, min_max_x, options)
          x2 = resize_x(x2, min_max_x, options)

          %Marker{marker | position: {x1, x2}}

        x ->
          %Marker{marker | position: resize_x(x, min_max_x, options)}
      end
    end)
  end

  @spec resize_x(number(), min_max(), Sparkline.opts()) :: number()
  defp resize_x(x, {min_x, max_x}, options) do
    width = options.width
    padding = options.padding

    (x - min_x) / (max_x - min_x) * (width - padding * 2) + padding
  end
end
