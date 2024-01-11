defmodule SimpleCharts do
  @moduledoc """
  General documentation for `SimpleCharts`.
  """

  @typedoc "Svg string."
  @type svg :: String.t()

  @doc """
  Convert a svg string into a base64 string to be used as a background-image.

  Notice: check for color encoding.

  ## Examples

      iex> SimpleCharts.as_background_image(svg_string)
      "data:image/svg+xml,%3Csvg..."

  """
  @spec as_background_image(svg()) :: String.t()
  def as_background_image(svg) when is_binary(svg) do
    ["data:image/svg+xml", Base.encode64(svg)] |> Enum.join(",")
  end
end
