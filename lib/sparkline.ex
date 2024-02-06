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

  @typedoc "A general sparkline option."
  @type option ::
          {:width, number()}
          | {:height, number()}
          | {:padding, number()}
          | {:placeholder, nil | String.t()}

  @typedoc "A general sparkline options list."
  @type options :: list(option())

  @typedoc "A dots-related sparkline option."
  @type dots_option :: {:radius, number()} | {:color, String.t()}

  @typedoc "A dots-related sparkline options list."
  @type dots_options :: list(option())

  @typedoc "A line-related sparkline option."
  @type line_option :: {:width, number()} | {:color, String.t()} | {:smoothing, float()}

  @typedoc "A line-related sparkline options list."
  @type line_options :: list(option())

  @typedoc "A area-related sparkline option."
  @type area_option :: {:color, String.t()}

  @typedoc "A area-related sparkline options list."
  @type area_options :: list(option())

  @typedoc """
  TODO.
  Sparkline struct.
  """
  @type t :: %Sparkline{
          datapoints: datapoints(),
          options: options(),
          dots_options: dots_options() | nil,
          line_options: line_options() | nil,
          area_options: area_options() | nil
        }
  @enforce_keys [:datapoints, :options]
  defstruct [:datapoints, :options, :dots_options, :line_options, :area_options]

  @doc """
  TODO: Add documentation
  """
  @spec new(datapoints()) :: Sparkline.t()
  @spec new(datapoints(), options()) :: Sparkline.t()
  def new(datapoints, options \\ []) do
    default_options = [width: 200, height: 100, padding: 6, placeholder: nil]
    options = Keyword.merge(default_options, options)

    %Sparkline{datapoints: datapoints, options: options}
  end

  @doc """
  TODO: Add documentation
  """
  @spec show_dots(Sparkline.t()) :: Sparkline.t()
  @spec show_dots(Sparkline.t(), dots_options()) :: Sparkline.t()
  def show_dots(sparkline, options \\ []) do
    default_dots_options = [radius: 1, color: "black"]
    options = Keyword.merge(default_dots_options, options)

    %Sparkline{sparkline | dots_options: options}
  end

  @doc """
  TODO: Add documentation
  """
  @spec show_line(Sparkline.t()) :: Sparkline.t()
  @spec show_line(Sparkline.t(), line_options()) :: Sparkline.t()
  def show_line(sparkline, options \\ []) do
    default_line_options = [width: 0.25, color: "black", smoothing: 0.2]
    options = Keyword.merge(default_line_options, options)

    %Sparkline{sparkline | line_options: options}
  end

  @doc """
  TODO: Add documentation
  """
  @spec show_area(Sparkline.t()) :: Sparkline.t()
  @spec show_area(Sparkline.t(), area_options()) :: Sparkline.t()
  def show_area(sparkline, options \\ []) do
    default_area_options = [color: "rgba(0, 0, 0, 0.2)"]
    options = Keyword.merge(default_area_options, options)

    %Sparkline{sparkline | area_options: options}
  end

  @doc """
  Return a valid SVG document representing a line chart with the given datapoints.

  ## Examples

  iex> Sparkline.Line.to_svg([{1, 1}, {2, 2}, {3, 3}])
  {:ok, svg_string}

  iex> Sparkline.Line.to_svg([{1, 1}, {2, 2}, {3, 3}], width: 240, height: 80)
  {:ok, svg_string}

  """
  @spec to_svg(Sparkline.t()) :: {:ok, svg()} | {:error, atom()}
  def to_svg(sparkline) do
    padding = Keyword.get(sparkline.options, :padding)

    with :ok <- check_dimension(Keyword.get(sparkline.options, :width), padding),
         :ok <- check_dimension(Keyword.get(sparkline.options, :height), padding),
         {:ok, datapoints} <- Datapoint.clean(sparkline.datapoints) do
      svg =
        if Enum.empty?(datapoints) do
          Draw.chart(sparkline)
        else
          {min_max_x, min_max_y} = Datapoint.get_min_max(datapoints)
          datapoints = Datapoint.resize(datapoints, min_max_x, min_max_y, sparkline.options)
          sparkline = %Sparkline{sparkline | datapoints: datapoints}

          Draw.chart(sparkline)
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
  @spec to_svg!(Sparkline.t()) :: svg()
  def to_svg!(sparkline) do
    case to_svg(sparkline) do
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

  # Private functions

  @spec check_dimension(number(), number()) :: :ok | {:error, atom()}
  defp check_dimension(length, padding) do
    if length - 2 * padding > 0,
      do: :ok,
      else: {:error, :invalid_dimension}
  end
end
