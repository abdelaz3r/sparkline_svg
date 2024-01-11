defmodule SimpleCharts do
  @moduledoc """
  General documentation for `SimpleCharts`.
  """

  @typedoc "Svg string."
  @type svg :: String.t()

  @doc """
  Convert a svg string into a Base64 string to be used as a background-image.

  ## Examples

      iex> SimpleCharts.as_background_image(svg_string)
      "data:image/svg+xml,%3Csvg..."

  """
  @spec as_background_image(svg()) :: String.t()
  def as_background_image(svg) when is_binary(svg) do
    ["data:image/svg+xml;base64", Base.encode64(svg)] |> Enum.join(",")
  end
end
