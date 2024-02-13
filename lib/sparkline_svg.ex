defmodule SparklineSvg do
  @moduledoc ~S"""
  SparklineSvg is a library to generate SVG sparkline charts.

  A [sparkline](https://en.wikipedia.org/wiki/Sparkline) is a small, simple chart that is drawn
  without axes or coordinates. It presents the general shape of the variation of a dataset at a
  glance.

  SparklineSvg allows you to create a sparkline chart from various data shapes and show the dots,
  the line, and the area under the line. You can also add markers to the chart to highlight
  specific spots.

  ## Usage example

  ``` elixir
  # Datapoints and general options
  datapoints = [1, 3, 2, 2, 5]
  options = [width: 200, height: 40]

  # A very simple line chart
  sparkline = SparklineSvg.new(datapoints, options)

  # Display what you want
  line_options = [width: 0.3, color: "green"]
  sparkline = SparklineSvg.show_line(sparkline, line_options)

  # Render the chart to an SVG string
  {:ok, svg} = SparklineSvg.to_svg(sparkline) # or
  svg = SparklineSvg.to_svg!(sparkline)
  ```

  ## Datapoints

  Datapoints are the values that will be used to draw the chart. They can be:
  - A **list of numbers**, where each number is a value for the `y` axis. The `x` axis will be the
    index of the number in the list.
  - A **list of tuples** with two values. The first value is the `x` axis and the second value is
    the `y` axis. The `x` value can be a `number`, a `DateTime`, a `Date`, a `Time`, or a
    `NaiveDateTime`. The `y` value must be a `number`.

  All values in the list must be of the same type.

  <!-- tabs-open -->
  ### Simple datapoints
  ``` elixir
  # Number datapoints
  datapoints = [1, 2, 3]
  datapoints = [1.1, 1.2, 1.3]

  # Datapoints with DateTime
  datapoints = [~U[2021-01-01 00:00:00Z], ~U[2021-01-02 00:00:00Z], ~U[2021-01-03 00:00:00Z]]

  # Datapoints with Date
  datapoints = [~D[2021-01-01], ~D[2021-01-02], ~D[2021-01-03]]

  # Datapoints with Time
  datapoints = [~T[00:01:00], ~T[00:02:00], ~T[00:03:00]]

  # Datapoints with NaiveDateTime
  datapoints = [~N[2021-01-01 00:00:00], ~N[2021-01-02 00:00:00], ~N[2021-01-03 00:00:00]]
  ```

  ### Tuple-based datapoints
  ``` elixir
  # Datapoints
  datapoints = [{1, 1}, {2, 2}, {3, 3}]
  datapoints = [{1.1, 1}, {1.2, 2}, {1.3, 3}]

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
  <!-- tabs-close -->

  ## Markers

  Markers are used to highlight specific spots on the chart. They differ from the datapoints and
  therefore are set separately from it. You can add as many markers as you want to a chart.

  There are two types of markers:
  - A single marker that will be rendered as a vertical line.
  - A range marker that will be rendered as a rectangle.

  Markers are not used to calculate the boundaries of the chart. If a marker is set outside the
  range of the chart, it will be rendered but won't be visible.

  <!-- tabs-open -->
  ### Single marker
  ``` elixir
  svg =
    datapoints
    |> SparklineSvg.new()
    |> SparklineSvg.show_line()
    |> SparklineSvg.add_marker(2)
    |> SparklineSvg.add_marker([3, 4])
    |> SparklineSvg.to_svg!()
  ```

  ### Range marker
  ``` elixir
  svg =
    datapoints
    |> SparklineSvg.new()
    |> SparklineSvg.show_line()
    |> SparklineSvg.add_marker({1, 2})
    |> SparklineSvg.add_marker([{3, 4}, {5, 6}])
    |> SparklineSvg.to_svg!()
  ```
  <!-- tabs-close -->

  ## Customization

  SparklineSvg allows you to customize the chart showing or hiding the dots, the line, and the area
  under the line.

  There are two ways to customize the chart:
  - Using the options like `:color` or `:width`.
  - Using the CSS classes option to give classes to SVG elements and then using CSS to style them.

  <!-- tabs-open -->
  ### Options
  ``` elixir
  svg =
    datapoints
    |> SparklineSvg.new(width: 100, height: 40, padding: 0.5, smoothing: 0.1, placeholder: "No data")
    |> SparklineSvg.show_dots(radius: 0.1, color: "rgb(255, 255, 255)")
    |> SparklineSvg.show_line(width: 0.5, color: "rgb(166, 218, 149)")
    |> SparklineSvg.show_area(color: "rgba(166, 218, 149, 0.2)")
    |> SparklineSvg.add_marker(1, stroke_color: "red", stroke_width: 0.5)
    |> SparklineSvg.to_svg!()
  ```

  ### CSS classes
  ``` elixir
  svg =
    datapoints
    |> SparklineSvg.new(smoothing: 0.1, placeholder: "No data", class: "sparkline")
    |> SparklineSvg.show_dots(class: "sparkline-dots")
    |> SparklineSvg.show_line(class: "sparkline-line")
    |> SparklineSvg.show_area(class: "sparkline-area")
    |> SparklineSvg.add_marker(1, class: "sparkline-marker")
    |> SparklineSvg.to_svg!()
  ```

  ### Tailwind classes
  ``` elixir
  svg =
    datapoints
    |> SparklineSvg.new(smoothing: 0.1, placeholder: "No data", class: "bg-transparent")
    |> SparklineSvg.show_dots(class: "fill-green")
    |> SparklineSvg.show_line(class: "stroke-green stroke-[0.5px] fill-transparent")
    |> SparklineSvg.show_area(class: "fill-green/10")
    |> SparklineSvg.add_marker(1, class: "stroke-red stroke-[0.5px] fill-transparent")
    |> SparklineSvg.to_svg!()
  ```
  <!-- tabs-close -->

  When using the CSS classes to style the chart, the other options like `:color` or `:width` will
  be ignored. However, some options (`:width`, `:height`, `padding`, `smoothing`, and
  `placeholder`), are used internally to render the chart and are required in any case.

  ### Available options

  Use the following options to customize the chart:

  - `:width` - the width of the chart, defaults to `200`.
  - `:height` - the height of the chart, defaults to `50`.
  - `:padding` - the padding of the chart, defaults to `2`. Not targetable with CSS classes.
    Padding has to be set to a value which `padding * 2 < width` and `padding * 2 < height`
    otherwise a `:invalid_dimension` error will be raised.
  - `:smoothing` - the smoothing of the line (`0` = no smoothing, above `0.4` it becomes
    unreadable), defaults to `0.15`. Not targetable with CSS classes.
  - `:placeholder` - a placeholder for an empty chart, defaults to `nil`. If set to `nil`, a chart
    with no datapoints will be an empty SVG document. Alternatively, you can set it to a string to
    display a message when the chart is empty. Not targetable with CSS classes.
  - `:class` - the value of the HTML class attribut of the chart, defaults to `nil`.
  - `:placeholder_class` - the value of the HTML class attribut of the placeholder, defaults to
  `nil`. It is the only way to style the placeholder.

  ### Dots options

  - `:radius` - the radius of the dots, defaults to `1`.
  - `:color` - the color of the dots, defaults to `"black"`.
  - `:class` - the value of the HTML class attribut of the dots, defaults to `nil`.

  ### Line options

  - `:width` - the width of the line, defaults to `0.25`.
  - `:color` - the color of the line, defaults to `"black"`.
  - `:class` - the value of the HTML class attribut of the line, defaults to `nil`.

  ### Area options

  - `:color` - the color of the area under the line, defaults to `"rgba(0, 0, 0, 0.1)"`.
  - `:class` - the value of the HTML class attribut of the area, defaults to `nil`.

  ### Marker options

  - `:stroke_width` - the stroke width of the marker, defaults to `0.25`.
  - `:stroke_color` - the stroke color of the marker, defaults to `"red"`.
  - `:fill_color` - the fill color of an area marker, defaults to `"rgba(255, 0, 0, 0.1)"`.
  - `:class` - the value of the HTML class attribut of the marker, defaults to `nil`.

  """

  alias SparklineSvg.Datapoint
  alias SparklineSvg.Draw
  alias SparklineSvg.Marker
  alias SparklineSvg.ReferenceLine

  @typedoc "A value for the x axis of the chart."
  @type x :: number() | DateTime.t() | Date.t() | Time.t() | NaiveDateTime.t()

  @typedoc "A number value for the y axis of the chart."
  @type y :: number()

  @typedoc "A datapoint for the chart."
  @type datapoint :: y() | {x(), y()}

  @typedoc """
  A list of datapoint.

  It can be a list of various types of datapoints, but all the datapoints in the list must be of the
  same type.
  """
  @type datapoints ::
          list(y())
          | list({number(), y()})
          | list({DateTime.t(), y()})
          | list({Date.t(), y()})
          | list({Time.t(), y()})
          | list({NaiveDateTime.t(), y()})

  @typedoc "A value or a two-tuple value for the x axis of the chart."
  @type marker :: x() | {x(), x()}

  @typedoc "A list of values or a list of two-tuple values for the x axis of the chart."
  @type markers ::
          list(number())
          | list(DateTime.t())
          | list(Date.t())
          | list(Time.t())
          | list(NaiveDateTime.t())
          | list({number(), number()})
          | list({DateTime.t(), DateTime.t()})
          | list({Date.t(), Date.t()})
          | list({Time.t(), Time.t()})
          | list({NaiveDateTime.t(), NaiveDateTime.t()})

  @typedoc "The type of reference line."
  @type ref_line :: :max | :min | :avg | :median

  @typedoc "Keyword list of options for the chart."
  @type options ::
          list(
            {:width, number()}
            | {:height, number()}
            | {:padding, number()}
            | {:smoothing, number()}
            | {:placeholder, nil | String.t()}
            | {:class, nil | String.t()}
            | {:placeholder_class, nil | String.t()}
          )

  @typedoc "Keyword list of options for the dots of the chart."
  @type dots_options ::
          list({:radius, number()} | {:color, String.t()} | {:class, nil | String.t()})

  @typedoc "Keyword list of options for the line of the chart."
  @type line_options ::
          list({:width, number()} | {:color, String.t()} | {:class, nil | String.t()})

  @typedoc "Keyword list of options for the area under the line of the chart."
  @type area_options :: list({:color, String.t()} | {:class, nil | String.t()})

  @typedoc "Keyword list of options for a marker of the chart."
  @type marker_options ::
          list(
            {:fill_color, String.t()}
            | {:stroke_color, String.t()}
            | {:stroke_width, number()}
            | {:class, nil | String.t()}
          )

  @typedoc "Keyword list of options for a reference line."
  @type ref_line_options ::
          list({:width, number()} | {:color, String.t()} | {:class, nil | String.t()})

  @typedoc false
  @type opts :: %{
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
  @type ref_lines :: %{optional(ref_line()) => ReferenceLine.t()}

  @typedoc false
  @type point :: %{x: number(), y: number()}

  @typedoc false
  @type points :: list(point())

  @typedoc false
  @type t :: %__MODULE__{
          datapoints: datapoints(),
          options: opts(),
          markers: list(Marker.t()),
          ref_lines: ref_lines()
        }
  @enforce_keys [:datapoints, :options, :markers, :ref_lines]
  defstruct [:datapoints, :options, :markers, :ref_lines]

  @doc ~S"""
  Create a new sparkline struct with the given datapoints and options.

  If neither `SparklineSvg.show_dots/2`, `SparklineSvg.show_line/2`, nor `SparklineSvg.show_area/2`
  are called, the rendered chart will be an empty SVG document.

  ## Examples

      iex> chart = SparklineSvg.new([1, 2])
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'

      iex> chart = SparklineSvg.new([1, 2], width: 240, height: 80)
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 240 80" xmlns="http://www.w3.org/2000/svg"></svg>'

  """
  @default_opts [
    width: 200,
    height: 50,
    padding: 2,
    smoothing: 0.15,
    placeholder: nil,
    class: nil,
    placeholder_class: nil
  ]

  @spec new(datapoints()) :: SparklineSvg.t()
  @spec new(datapoints(), options()) :: SparklineSvg.t()
  def new(datapoints, options \\ []) do
    options =
      @default_opts
      |> Keyword.merge(options)
      |> Map.new()
      |> Map.merge(%{dots: nil, line: nil, area: nil})

    %SparklineSvg{datapoints: datapoints, options: options, markers: [], ref_lines: %{}}
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given dots options.

  Calling this function multiple times will override the previous dots options. If no options are
  given, the dots will be shown with the default options.

  ## Examples

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_dots()
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" r="1" fill="black" /><circle cx="198.0" cy="2.0" r="1" fill="black" /></svg>'

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_dots(radius: 0.5, color: "red")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" r="0.5" fill="red" /><circle cx="198.0" cy="2.0" r="0.5" fill="red" /></svg>'

  """

  @default_dots_opts [radius: 1, color: "black", class: nil]

  @spec show_dots(SparklineSvg.t()) :: SparklineSvg.t()
  @spec show_dots(SparklineSvg.t(), dots_options()) :: SparklineSvg.t()
  def show_dots(sparkline, options \\ []) do
    dots_options =
      @default_dots_opts
      |> Keyword.merge(options)
      |> Map.new()

    %SparklineSvg{sparkline | options: %{sparkline.options | dots: dots_options}}
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given line options.

  Calling this function multiple times will override the previous line options. If no options are
  given, the line will be shown with the default options.

  ## Examples

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_line()
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_line(width: 0.1, color: "green")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="green" stroke-width="0.1" /></svg>'

  """

  @default_line_opts [width: 0.25, color: "black", class: nil]

  @spec show_line(SparklineSvg.t()) :: SparklineSvg.t()
  @spec show_line(SparklineSvg.t(), line_options()) :: SparklineSvg.t()
  def show_line(sparkline, options \\ []) do
    line_options =
      @default_line_opts
      |> Keyword.merge(options)
      |> Map.new()

    %SparklineSvg{sparkline | options: %{sparkline.options | line: line_options}}
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given area options.

  Calling this function multiple times will override the previous area options. If no options are
  given, the area will be shown with the default options.

  ## Examples

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_area()
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" fill="rgba(0, 0, 0, 0.1)" stroke="none" /></svg>'

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_area(color: "rgba(0, 255, 255, 0.2)")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" fill="rgba(0, 255, 255, 0.2)" stroke="none" /></svg>'

  """

  @default_area_opts [color: "rgba(0, 0, 0, 0.1)", class: nil]

  @spec show_area(SparklineSvg.t()) :: SparklineSvg.t()
  @spec show_area(SparklineSvg.t(), area_options()) :: SparklineSvg.t()
  def show_area(sparkline, options \\ []) do
    area_options =
      @default_area_opts
      |> Keyword.merge(options)
      |> Map.new()

    %SparklineSvg{sparkline | options: %{sparkline.options | area: area_options}}
  end

  @doc ~S"""
  TODO.
  """

  @spec show_ref_line(SparklineSvg.t(), ref_line()) :: SparklineSvg.t()
  @spec show_ref_line(SparklineSvg.t(), ref_line(), ref_line_options()) :: SparklineSvg.t()
  def show_ref_line(sparkline, type, options \\ []) do
    ref_line = ReferenceLine.new(type, options)
    ref_lines = Map.put(sparkline.ref_lines, type, ref_line)

    %SparklineSvg{sparkline | ref_lines: ref_lines}
  end

  @doc ~S"""
  Add one or many markers to a sparkline struct with the given options.

  When calling this function with a list of markers, the options will be applied to all the markers.

  If you want to apply different options to different markers, you can call this function multiple
  times with a single marker and the desired options.

  Markers are not used to calculate the boudaries of the chart. If you set a marker outside the range
  of the chart, it will be rendered but won't be visible.

  ## Examples

      iex> chart = SparklineSvg.new([1, 3]) |> SparklineSvg.add_marker(2)
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M394.0,0.0V50" fill="none" stroke="red" stroke-width="0.25" /></svg>'

      iex> chart = SparklineSvg.new([1, 3]) |> SparklineSvg.add_marker({2.1, 2.4})
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><rect x="413.6" y="-0.25" width="58.8" height="50.5" fill="rgba(255, 0, 0, 0.1)" stroke="red" stroke-width="0.25" /></svg>'

      iex> chart = SparklineSvg.new([1, 3]) |> SparklineSvg.add_marker(2, stroke_color: "rgba(0, 255, 0, 0.2)")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M394.0,0.0V50" fill="none" stroke="rgba(0, 255, 0, 0.2)" stroke-width="0.25" /></svg>'

  """
  @spec add_marker(SparklineSvg.t(), marker() | markers()) :: SparklineSvg.t()
  @spec add_marker(SparklineSvg.t(), marker() | markers(), marker_options()) :: SparklineSvg.t()
  def add_marker(sparkline, markers, options \\ [])

  def add_marker(sparkline, markers, options) when is_list(markers) do
    markers = Enum.map(markers, fn marker -> Marker.new(marker, options) end)
    %SparklineSvg{sparkline | markers: markers ++ sparkline.markers}
  end

  def add_marker(sparkline, marker, options) do
    add_marker(sparkline, [marker], options)
  end

  @doc ~S"""
  Return a valid SVG document from a sparkline struct.

  ## Examples

      iex> SparklineSvg.new([1, 2]) |> SparklineSvg.to_svg()
      {:ok, ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'}

      iex> SparklineSvg.new([1, 2], width: 10, padding: 10) |> SparklineSvg.to_svg()
      {:error, :invalid_dimension}

  """
  @spec to_svg(SparklineSvg.t()) :: {:ok, String.t()} | {:error, atom()}
  def to_svg(sparkline) do
    %{width: width, height: height, padding: padding} = sparkline.options

    with :ok <- check_dimension(width, padding),
         :ok <- check_dimension(height, padding),
         {:ok, datapoints, type} <- Datapoint.clean(sparkline.datapoints),
         {:ok, markers} <- Marker.clean(sparkline.markers, type),
         {:ok, ref_lines} <- ReferenceLine.clean(sparkline.ref_lines) do
      svg =
        %SparklineSvg{sparkline | datapoints: datapoints, markers: markers, ref_lines: ref_lines}
        |> compute()
        |> Draw.chart()
        |> :erlang.iolist_to_binary()

      {:ok, svg}
    end
  end

  @doc ~S"""
  Return a valid SVG document from a sparkline struct.

  ## Examples

      iex> SparklineSvg.new([1, 2]) |> SparklineSvg.to_svg!()
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'

      iex> SparklineSvg.new([1, 2], width: 10, padding: 10) |> SparklineSvg.to_svg!()
      ** (SparklineSvg.Error) invalid_dimension

  """
  @spec to_svg!(SparklineSvg.t()) :: String.t()
  def to_svg!(sparkline) do
    case to_svg(sparkline) do
      {:ok, svg} -> svg
      {:error, reason} -> raise(SparklineSvg.Error, Atom.to_string(reason))
    end
  end

  @doc ~S"""
  Convert a svg string into a Base64 string to be used, for example, as a background-image.

  Note that using SVG as a background-image has some limitations. For example, CSS Selectors in a
  host document cannot query an SVG document that is embedded as an external resource as opposed to
  being inlined with the host document markup.

  ## Examples

      iex> svg = SparklineSvg.new([1, 2]) |> SparklineSvg.to_svg!()
      iex> SparklineSvg.as_data_uri(svg)
      "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiB2aWV3Qm94PSIwIDAgMjAwIDUwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjwvc3ZnPg=="

  """
  @spec as_data_uri(String.t()) :: String.t()
  def as_data_uri(svg) when is_binary(svg) do
    ["data:image/svg+xml;base64", Base.encode64(svg)] |> Enum.join(",")
  end

  # Private functions

  @spec compute(SparklineSvg.t()) :: SparklineSvg.t()
  defp compute(%SparklineSvg{datapoints: []} = sparkline) do
    sparkline
  end

  defp compute(%SparklineSvg{} = sparkline) do
    %{datapoints: datapoints, ref_lines: ref_lines, markers: markers, options: options} =
      sparkline

    {min_max_x, min_max_y} = Datapoint.get_min_max(datapoints)

    datapoints = Datapoint.resize(datapoints, min_max_x, min_max_y, options)
    ref_lines = ReferenceLine.compute(ref_lines, datapoints)
    markers = Marker.resize(markers, min_max_x, options)

    %SparklineSvg{
      sparkline
      | datapoints: datapoints,
        markers: markers,
        ref_lines: ref_lines
    }
  end

  @spec check_dimension(number(), number()) :: :ok | {:error, atom()}
  defp check_dimension(length, padding) do
    if length - 2 * padding > 0,
      do: :ok,
      else: {:error, :invalid_dimension}
  end
end
