defmodule Sparkline do
  @moduledoc ~S"""
  `Sparkline` uses a list of datapoints to return a line chart in SVG format.

  ## Usage example:

  ``` elixir
  # Datapoints
  datapoints = [{1, 1}, {2, 2}, {3, 3}]

  # General options
  options = [width: 100, height: 40]

  # A very simple line chart
  sparkline = Sparkline.new(datapoints, options)

  # Display what you want
  line_options = [width: 0.25, color: "black"]
  sparkline = Sparkline.show_line(sparkline, line_options)

  {:ok, svg} = Sparkline.to_svg(sparkline) # or
  svg = Sparkline.to_svg!(sparkline)
  ```

  ### Customization

  `Sparkline` allows you to customize the chart showing or hiding the dots, the line, and the area
  under the line.

  ``` elixir
  # A more complex sparkline
  {:ok, svg} =
    datapoints
    |> Sparkline.new(width: 100, height: 40, padding: 0.5, smoothing: 0.1, placeholder: "No data")
    |> Sparkline.show_dot(radius: 0.1, color: "rgb(255, 255, 255)")
    |> Sparkline.show_line(width: 0.05, color: "rgba(166, 218, 149)")
    |> Sparkline.show_area(color: "rgba(166, 218, 149, 0.2)")
    |> Sparkline.to_svg()
  ```

  ## Options

  Use the following options to customize the chart:

  - `width`: The width of the chart, defaults to `200`.
  - `height`: The height of the chart, defaults to `100`.
  - `padding`: The padding of the chart, defaults to `6`.
  - `smoothing`: The smoothing of the line (`0` = no smoothing, above `0.5` it becomes unreadable),
    defaults to `0.2`.
  - `placeholder`: A placeholder for an empty chart, defaults to `nil`. If set to `nil`, the chart
    will be an empty SVG document. Alternatively, you can set it to a string to display a message
    when the chart is empty.

  ### Dots options

  - `radius`: The radius of the dots, defaults to `1`.
  - `color`: The color of the dots, defaults to `"black"`.

  ### Line options

  - `width`: The width of the line, defaults to `0.25`.
  - `color`: The color of the line, defaults to `"black"`.

  ### Area options

  - `color`: The color of the area under the line, defaults to `"rgba(0, 0, 0, 0.2)"`.

  ## Datapoints

  A datapoint can be a pair of `DateTime` and `number`, `Date` and `number`, `Time` and `number`,
  or simply two `numbers`. However, the datapoints in a list must all be of the same type.

  ``` elixir
  # Datapoints
  datapoints = [{1, 1}, {2, 2}, {3, 3}]

  # Datapoints with DateTime
  datapoints = [
    {~U[2021-01-01 00:00:00Z], 1},
    {~U[2021-01-02 00:00:00Z], 2},
    {~U[2021-01-03 00:00:00Z], 3}
  ]

  # Datapoints with Date
  datapoints = [{~D[2021-01-01], 1}, {~D[2021-01-02], 2}, {~D[2021-01-03], 3}]

  # Datapoints with Time
  datapoints = [{~T[00:01:00], 1}, {~T[00:02:00], 2}, {~T[00:03:00], 3}]

  # Datapoints with NaiveDateTime
  datapoints = [
    {~N[2021-01-01 00:00:00], 1},
    {~N[2021-01-02 00:00:00], 2},
    {~N[2021-01-03 00:00:00], 3}
  ]
  ```
  """

  alias Sparkline.Datapoint
  alias Sparkline.Draw

  @typedoc "A valid SVG string."
  @type svg :: String.t()

  @typedoc """
  A datapoint can be a pair of DateTime and number, Date and number, Time and number, or simply two
  numbers.
  """
  @type datapoint ::
          number()
          | {DateTime.t(), number()}
          | {Date.t(), number()}
          | {Time.t(), number()}
          | {NaiveDateTime.t(), number()}
          | {number(), number()}

  @typedoc """
  A list of datapoints. The data types in the list correspond to those defined for datapoint.
  """
  @type datapoints ::
          list(number())
          | list({DateTime.t(), number()})
          | list({Date.t(), number()})
          | list({Time.t(), number()})
          | list({NaiveDateTime.t(), number()})
          | list({number(), number()})

  @typedoc "A general sparkline option."
  @type option ::
          {:width, number()}
          | {:height, number()}
          | {:padding, number()}
          | {:smoothing, float()}
          | {:placeholder, nil | String.t()}
          | {:class, nil | String.t()}
          | {:placeholder_class, nil | String.t()}

  @typedoc "A general sparkline options list."
  @type options :: list(option())

  @typedoc "A dots-related sparkline option."
  @type dots_option :: {:radius, number()} | {:color, String.t()} | {:class, nil | String.t()}

  @typedoc "A dots-related sparkline options list."
  @type dots_options :: list(dots_option())

  @typedoc "A line-related sparkline option."
  @type line_option :: {:width, number()} | {:color, String.t()} | {:class, nil | String.t()}

  @typedoc "A line-related sparkline options list."
  @type line_options :: list(line_option())

  @typedoc "A area-related sparkline option."
  @type area_option :: {:color, String.t()} | {:class, nil | String.t()}

  @typedoc "A area-related sparkline options list."
  @type area_options :: list(area_option())

  @typedoc false
  @type internal_options :: %{
          width: number(),
          height: number(),
          padding: number(),
          smoothing: float(),
          placeholder: nil | String.t(),
          class: nil | String.t(),
          placeholder_class: nil | String.t(),
          dots: nil | map(),
          line: nil | map(),
          area: nil | map()
        }

  @typedoc false
  @type t :: %Sparkline{
          datapoints: datapoints(),
          options: internal_options()
        }
  @enforce_keys [:datapoints, :options]
  defstruct [:datapoints, :options]

  @doc ~S"""
  Create a new sparkline struct with the given datapoints and options.

  ## Examples

    iex> Sparkline.new([{1, 1}, {2, 2}])
    %Sparkline{datapoints: [{1, 1}, {2, 2}]}

    iex> Sparkline.new([{1, 1}, {2, 2}], width: 240, height: 80)
    %Sparkline{datapoints: [{1, 1}, {2, 2}], options: %{width: 240, height: 80}}

  """
  @spec new(datapoints()) :: Sparkline.t()
  @spec new(datapoints(), options()) :: Sparkline.t()
  def new(datapoints, options \\ []) do
    options =
      [
        width: 200,
        height: 100,
        padding: 6,
        smoothing: 0.2,
        placeholder: nil,
        class: nil,
        placeholder_class: nil
      ]
      |> Keyword.merge(options)
      |> Map.new()
      |> Map.merge(%{dots: nil, line: nil, area: nil})

    %Sparkline{datapoints: datapoints, options: options}
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given dots options. Calling
  this function multiple times will override the previous dots options. If no options are given, the
  dots will be shown with the default options.

  ## Examples

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.show_dots()
    %Sparkline{datapoints: [{1, 1}, {2, 2}]}

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.show_dots(radius: 0.5, color: "red")
    %Sparkline{datapoints: [{1, 1}, {2, 2}], options: %{dots: %{radius: 0.5, color: "red"}}}

  """
  @spec show_dots(Sparkline.t()) :: Sparkline.t()
  @spec show_dots(Sparkline.t(), dots_options()) :: Sparkline.t()
  def show_dots(sparkline, options \\ []) do
    dots_options =
      [radius: 1, color: "black", class: nil]
      |> Keyword.merge(options)
      |> Map.new()

    %Sparkline{sparkline | options: %{sparkline.options | dots: dots_options}}
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given line options. Calling
  this function multiple times will override the previous line options. If no options are given, the
  line will be shown with the default options.

  ## Examples

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.show_line()
    %Sparkline{datapoints: [{1, 1}, {2, 2}]}

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.show_line(width: 0.25, color: "black")
    %Sparkline{datapoints: [{1, 1}, {2, 2}], options: %{line: %{width: 0.25, color: "black"}}}

  """
  @spec show_line(Sparkline.t()) :: Sparkline.t()
  @spec show_line(Sparkline.t(), line_options()) :: Sparkline.t()
  def show_line(sparkline, options \\ []) do
    line_options =
      [width: 0.25, color: "black", class: nil]
      |> Keyword.merge(options)
      |> Map.new()

    %Sparkline{sparkline | options: %{sparkline.options | line: line_options}}
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given area options. Calling
  this function multiple times will override the previous area options. If no options are given, the
  area will be shown with the default options.

  ## Examples

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.show_area()
    %Sparkline{datapoints: [{1, 1}, {2, 2}]}

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.show_area(color: "rgba(0, 0, 0, 0.2)")
    %Sparkline{datapoints: [{1, 1}, {2, 2}], options: %{area: %{color: "rgba(0, 0, 0, 0.2"}}}

  """
  @spec show_area(Sparkline.t()) :: Sparkline.t()
  @spec show_area(Sparkline.t(), area_options()) :: Sparkline.t()
  def show_area(sparkline, options \\ []) do
    area_options =
      [color: "rgba(0, 0, 0, 0.2)", class: nil]
      |> Keyword.merge(options)
      |> Map.new()

    %Sparkline{sparkline | options: %{sparkline.options | area: area_options}}
  end

  @doc ~S"""
  Return a valid SVG document from a sparkline struct.

  Examples:

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.to_svg()
    {:ok, svg}

    iex> Sparkline.new([{1, 1}, {2, 2}], width: 10, padding: 10) |> Sparkline.to_svg()
    {:error, :invalid_dimension}

  """
  @spec to_svg(Sparkline.t()) :: {:ok, svg()} | {:error, atom()}
  def to_svg(sparkline) do
    %{width: width, height: height, padding: padding} = sparkline.options

    with :ok <- check_dimension(width, padding),
         :ok <- check_dimension(height, padding),
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

      {:ok, :erlang.iolist_to_binary(svg)}
    end
  end

  @doc ~S"""
  Return a valid SVG document from a sparkline struct.

  Examples:

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.to_svg!()
    svg

    iex> Sparkline.new([{1, 1}, {2, 2}], width: 10, padding: 10) |> Sparkline.to_svg!()
    ** (Sparkline.Error) invalid_dimension

  """
  @spec to_svg!(Sparkline.t()) :: svg()
  def to_svg!(sparkline) do
    case to_svg(sparkline) do
      {:ok, svg} -> svg
      {:error, reason} -> raise(Sparkline.Error, Atom.to_string(reason))
    end
  end

  @doc ~S"""
  Convert a svg string into a Base64 string to be used, for example, as a background-image.

  Examples:

    iex> Sparkline.new([{1, 1}, {2, 2}]) |> Sparkline.to_svg!() |> Sparkline.as_data_uri()
    "data:image/svg+xml;base64,PHN2ZyB3aWR0aD..."

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
