defmodule Sparkline do
  @moduledoc """
  `Sparkline.Line` uses a list of datapoints to return a line chart in SVG format.

  ## Usage example:

  ``` elixir
  # Datapoints
  datapoints = [{1, 1}, {2, 2}, {3, 3}]

  # A very simple line chart
  Sparkline.Line.to_svg(datapoints)

  # A line chart with different sizes
  Sparkline.Line.to_svg(datapoints, width: 240, height: 80)

  # A complete example of a line chart
  options = [
    width: 100,
    height: 40,
    padding: 0.5,
    show_dot: false,
    dot_radius: 0.1,
    dot_color: "rgb(255, 255, 255)",
    line_color: "rgba(166, 218, 149)",
    line_width: 0.05,
    line_smoothing: 0.1
  ]

  Sparkline.Line.to_svg(datapoints, options)
  ```

  ## Options

  Use the following options to customize the chart:

  - `width`: The width of the chart, defaults to `200`.
  - `height`: The height of the chart, defaults to `100`.
  - `padding`: The padding of the chart, defaults to `6`.
  - `show_dot`: A boolean to decide whether to show dots or not, defaults to `true`.
  - `dot_radius`: The radius of the dots, defaults to `1`.
  - `dot_color`: The color of the dots, defaults to `"black"`.
  - `show_line`: A boolean to decide whether to show the line or not, defaults to `true`.
  - `line_width`: The width of the line, defaults to `0.25`.
  - `line_color`: The color of the line, defaults to `"black"`.
  - `line_smoothing`: The smoothing of the line (`0` = no smoothing, above `0.5` it becomes unreadable),
    defaults to `0.2`.
  - `show_area`: A boolean to decide whether to show the area under the line or not, defaults to `false`.
  - `area_color`: The color of the area under the line, defaults to `"rgba(0, 0, 0, 0.2)"`.
  - `placeholder`: A placeholder for an empty chart, defaults to `"No data"`.

  ## Datapoints

  A datapoint can be a pair of `DateTime` and `number`, `Date` and `number`, `Time` and `number`,
  or simply two `numbers`. However, the datapoints in a list must all be of the same type.

  ``` elixir
  # Datapoints
  datapoints = [{1, 1}, {2, 2}, {3, 3}]

  # Datapoints with DateTime
  datapoints = [{~N[2021-01-01 00:00:00], 1}, {~N[2021-01-02 00:00:00], 2}, {~N[2021-01-03 00:00:00], 3}]

  # Datapoints with Date
  datapoints = [{~D[2021-01-01], 1}, {~D[2021-01-02], 2}, {~D[2021-01-03], 3}]

  # Datapoints with Time
  datapoints = [{~T[00:00:00], 1}, {~T[00:00:00], 2}, {~T[00:00:00], 3}]
  ```
  """

  alias Sparkline.Datapoint
  alias Sparkline.Draw

  @typedoc "Svg string."
  @type svg :: String.t()

  @typedoc """
  A datapoint can be a pair of DateTime and number, Date and number, Time and number,
  or simply two numbers.
  """
  @type datapoint ::
          {DateTime.t(), number()}
          | {Date.t(), number()}
          | {Time.t(), number()}
          | {number(), number()}

  @typedoc """
  A list of datapoints. The data types in the list correspond to those defined for
  datapoint.
  """
  @type datapoints ::
          list({DateTime.t(), number()})
          | list({Date.t(), number()})
          | list({Time.t(), number()})
          | list({number(), number()})

  @typedoc "An option for the chart."
  @type option ::
          {:width, number()}
          | {:height, number()}
          | {:padding, number()}
          | {:show_dot, boolean()}
          | {:dot_radius, number()}
          | {:dot_color, String.t()}
          | {:show_line, boolean()}
          | {:line_width, number()}
          | {:line_color, String.t()}
          | {:line_smoothing, float()}
          | {:show_area, boolean()}
          | {:area_color, String.t()}
          | {:placeholder, String.t()}

  @typedoc "An options list for the chart."
  @type options :: list(option())

  # Default options
  @default_options [
    width: 200,
    height: 100,
    padding: 6,
    show_dot: true,
    dot_radius: 1,
    dot_color: "black",
    show_line: true,
    line_width: 0.25,
    line_color: "black",
    line_smoothing: 0.2,
    show_area: false,
    area_color: "rgba(0, 0, 0, 0.2)",
    placeholder: "No data"
  ]

  @doc """
  Return a valid SVG document representing a line chart with the given datapoints.

  ## Examples

  iex> Sparkline.Line.to_svg([{1, 1}, {2, 2}, {3, 3}])
  {:ok, svg_string}

  iex> Sparkline.Line.to_svg([{1, 1}, {2, 2}, {3, 3}], width: 240, height: 80)
  {:ok, svg_string}

  """
  @spec to_svg(datapoints()) :: {:ok, svg()} | {:error, atom()}
  @spec to_svg(datapoints(), options()) :: {:ok, svg()} | {:error, atom()}
  def to_svg(datapoints, options \\ []) do
    options = Keyword.merge(@default_options, options)
    padding = Keyword.get(options, :padding)

    with :ok <- Datapoint.check_dimension(Keyword.get(options, :width), padding),
         :ok <- Datapoint.check_dimension(Keyword.get(options, :height), padding),
         {:ok, datapoints} <- Datapoint.clean(datapoints) do
      svg =
        if Enum.empty?(datapoints) do
          Draw.chart([], options)
        else
          {min_max_x, min_max_y} = Datapoint.get_min_max(datapoints)

          datapoints
          |> Datapoint.resize(min_max_x, min_max_y, options)
          |> Draw.chart(options)
        end

      {:ok, svg}
    end
  end

  @doc """
  Return a valid SVG document representing a line chart with the given datapoints.

  ## Examples

  iex> Sparkline.Line.to_svg!([{1, 1}, {2, 2}, {3, 3}])
  svg_string

  iex> Sparkline.Line.to_svg!([{1, 1}, {2, 2}, {3, 3}], width: 240, height: 80)
  svg_string

  """
  @spec to_svg!(datapoints()) :: svg()
  @spec to_svg!(datapoints(), options()) :: svg()
  def to_svg!(datapoints, options \\ []) do
    case to_svg(datapoints, options) do
      {:ok, svg} -> svg
      {:error, reason} -> raise(Sparkline.Error, Atom.to_string(reason))
    end
  end

  @doc """
  Convert a svg string into a Base64 string to be used, for example. as a background-image.

  ## Examples

      iex> Sparkline.as_data_uri(svg_string)
      "data:image/svg+xml,%3Csvg..."

  """
  @spec as_data_uri(svg()) :: String.t()
  def as_data_uri(svg) when is_binary(svg) do
    ["data:image/svg+xml;base64", Base.encode64(svg)] |> Enum.join(",")
  end
end
