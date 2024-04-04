defmodule SparklineSvg do
  @moduledoc ~S"""
  SparklineSvg is a library to generate SVG sparkline charts.

  A [sparkline](https://en.wikipedia.org/wiki/Sparkline) is a small, simple chart that is drawn
  without axes or coordinates. It presents the general shape of the variation of a dataset at a
  glance.

  SparklineSvg allows you to create a sparkline chart from various data shapes and show the dots,
  the line, and the area under the line. You can also add markers to the chart to highlight
  specific spots. You can also show common reference lines.

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

  All `x` values in the list must be of the same type.

  <!-- tabs-open -->
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

  ### Simple datapoints
  ``` elixir
  # Number datapoints
  datapoints = [1, 2, 3]
  datapoints = [1.1, 1.2, 1.3]
  ```
  <!-- tabs-close -->

  ## Markers

  Markers are used to highlight specific spots on the chart. They differ from the datapoints and
  therefore are set separately from it. You can add as many markers as you want to a chart.

  There are two types of markers:
  - A single marker that will be rendered as a vertical line that span the entire height of the
    chart.
  - A range marker that will be rendered as a rectangle that span the entire height of the chart.

  Markers are not used to calculate the boundaries of the chart. If a marker is set outside the
  range of the chart, it will be rendered but won't be visible.

  We always set the `x` value of the marker (position on the x axis). The marker must be of the
  same type as the `x` axis of the chart.

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

  ## Reference lines

  Reference lines are used to show common reference line on the chart. You can add as many
  reference lines as you want. Reference lines are displayed as horizontal lines that span the
  entire width of the chart.

  There are currently five basic types of supported reference lines: `:max`, `:min`, `:avg`,
  `:median`, and percentile. You can implement custom reference lines.

  See the documentation of `m:SparklineSvg.ReferenceLine` for more information on how to use.

  ## Window

  Window option can be used to set the minimum and maximum value of the x axis of the chart.
  Normally the window is automatically calculated based on the datapoints. You can set the min or
  the max value of the window or both.

  Outside of window datapoints will be discarded before calculation of the reference lines.

  This can be useful to have a consistent chart when the data is not consistent or to have multiple
  charts with the same window.

  ## Customization

  SparklineSvg allows you to customize the chart showing or hiding the dots, the line, and the area
  under the line as well as markers and reference lines.

  There are two ways to customize the chart:
  - Using the options like `:color` or `:dasharray`.
  - Using the CSS classes option to give classes to SVG elements and then using CSS to style them.

  <!-- tabs-open -->
  ### Options
  ``` elixir
  svg =
    [3, 2, 4, 1, 5, 1, 4]
    |> SparklineSvg.new(width: 100, height: 40, padding: 0.5)
    |> SparklineSvg.set_placeholder("No data")
    |> SparklineSvg.show_dots(radius: 0.1, color: "rgb(255, 255, 255)")
    |> SparklineSvg.show_line(width: 0.5, color: "rgb(166, 218, 149)")
    |> SparklineSvg.show_area(color: "rgba(166, 218, 149, 0.2)")
    |> SparklineSvg.add_marker(1, stroke_color: "red", stroke_width: 0.5)
    |> SparklineSvg.show_ref_line(:max, width: 0.3, color: "red")
    |> SparklineSvg.to_svg!()
  ```

  ### CSS classes
  ``` elixir
  svg =
    [3, 2, 4, 1, 5, 1, 4]
    |> SparklineSvg.new(width: 100, height: 40, padding: 0.5)
    |> SparklineSvg.set_placeholder("No data", class: "sparkline")
    |> SparklineSvg.show_dots(class: "sparkline-dots")
    |> SparklineSvg.show_line(class: "sparkline-line")
    |> SparklineSvg.show_area(class: "sparkline-area")
    |> SparklineSvg.add_marker(1, class: "sparkline-marker")
    |> SparklineSvg.show_ref_line(:max, class: "sparkline-max-value")
    |> SparklineSvg.to_svg!()
  ```

  ### Tailwind classes
  ``` elixir
  svg =
    [3, 2, 4, 1, 5, 1, 4]
    |> SparklineSvg.new(width: 100, height: 40, padding: 0.5)
    |> SparklineSvg.set_placeholder("No data", class: "fill-red")
    |> SparklineSvg.show_dots(class: "fill-green")
    |> SparklineSvg.show_line(class: "stroke-green stroke-[0.5px] fill-transparent")
    |> SparklineSvg.show_area(class: "fill-green/10")
    |> SparklineSvg.add_marker(1, class: "stroke-red stroke-[0.5px] fill-transparent")
    |> SparklineSvg.show_ref_line(:max, class: "stroke-red stroke-[0.3px]")
    |> SparklineSvg.to_svg!()
  ```
  <!-- tabs-close -->

  When using the CSS classes to style the chart, the other options like `:color` or `:dasharray`
  will be ignored. However, some options (`:width`, `:height`, `:padding`, `:smoothing`), are used
  internally to render the chart and are required in any case.

  ### Available options

  Use the following options to customize the chart:

  - `:width` - the width of the chart, defaults to `200`.
  - `:height` - the height of the chart, defaults to `50`.
  - `:padding` - the padding of the chart, defaults to `2`. Not targetable with CSS classes.
    The padding can be one the following:
    - A single positive `number()` that will be used for all sides.
    - A keyword list where the keys are `:top`, `:right`, `:bottom`, and `:left` and the values are
      a positive `number()` for each side; missing sides will be set to the default value.

    Padding has to be set to a value which `left_padding + right_padding < width` and `top_padding
    + bottom_padding < height` otherwise a `:invalid_dimension` error will be raised.
  - `:smoothing` - the smoothing of the line (`0` = no smoothing, above `0.4` it becomes
    unreadable), defaults to `0.15`. Not targetable with CSS classes.
  - `:precision` - the maximum precision of the values used to render the chart, defaults to `3`.
    Not targetable with CSS classes. The precision can be set between `0` and `15`. The greater the
    precision, the more accurate the chart will be but the heavier the SVG will be.
  - `:class` - the value of the HTML class attribute of the chart, defaults to `nil`.
  - `:sort` - can be one of these atoms: `:asc`, `:desc`, or `none`. Defaults to `:asc`. If set to
    `:asc` or `:desc`, the datapoints will be sorted by the `x` axis before rendering the chart.
    If set to `:none`, the datapoints will be rendered in the order they are given, potentially
    resulting in unexpected visual representations.

  ### Dots options

  - `:radius` - the radius of the dots, defaults to `1`.
  - `:color` - the color of the dots, defaults to `"black"`.
  - `:class` - the value of the HTML class attribute of the dots, defaults to `nil`.

  ### Line options

  - `:width` - the width of the line, defaults to `0.25`.
  - `:color` - the color of the line, defaults to `"black"`.
  - `:dasharray` - the value of the HTML stroke-dasharray attribute of the line, defaults to `""`.
    Valid dasharray values can be found
    [here](https://developer.mozilla.org/en-US/docs/Web/SVG/attribute/stroke-dasharray).
  - `:class` - the value of the HTML class attribute of the line, defaults to `nil`.

  ### Area options

  - `:color` - the color of the area under the line, defaults to `"rgba(0, 0, 0, 0.1)"`.
  - `:class` - the value of the HTML class attribute of the area, defaults to `nil`.

  ### Marker options

  - `:stroke_width` - the stroke width of the marker, defaults to `0.25`.
  - `:stroke_color` - the stroke color of the marker, defaults to `"red"`.
  - `:stroke_dasharray` - the value of the HTML stroke-dasharray attribute of the marker, defaults
    to `""`. Valid dasharray values can be found
    [here](https://developer.mozilla.org/en-US/docs/Web/SVG/attribute/stroke-dasharray).
  - `:fill_color` - the fill color of an area marker, defaults to `"rgba(255, 0, 0, 0.1)"`.
  - `:class` - the value of the HTML class attribute of the marker, defaults to `nil`.

  ### Reference line options

  - `:width` - the width of the reference line, defaults to `0.25`.
  - `:color` - the color of the reference line, defaults to `"rgba(0, 0, 0, 0.5)"`.
  - `:dasharray` - the value of the HTML stroke-dasharray attribute of the reference line, defaults
    to `""`. Valid dasharray values can be found
    [here](https://developer.mozilla.org/en-US/docs/Web/SVG/attribute/stroke-dasharray).
  - `:class` - the value of the HTML class attribute of the reference line, defaults to `nil`.

  ### Window options

  - `:min` - the minimum value of the window, defaults to `:auto`. The value must be of the same
    type as the `x` axis of the chart, or `:auto`.
  - `:max` - the maximum value of the window, defaults to `:auto`. The value must be of the same
    type as the `x` axis of the chart, or `:auto`.

  ### Placeholder options

  - `:class` - the value of the HTML class attribute of the placeholder, defaults to `nil`. It is
  currently the only way to style the placeholder.

  """

  alias SparklineSvg.Core
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
  @type ref_line :: :max | :min | :avg | :median | (Core.points() -> Core.y())

  @typedoc "Padding options for the chart."
  @type padding ::
          number()
          | list({:top, number()} | {:right, number()} | {:bottom, number()} | {:left, number()})

  @typedoc "Sorting options for the chart."
  @type sort_options :: :asc | :desc | :none

  @typedoc "Keyword list of options for the chart."
  @type options ::
          list(
            {:width, number()}
            | {:height, number()}
            | {:padding, padding()}
            | {:smoothing, number()}
            | {:precision, non_neg_integer()}
            | {:class, nil | String.t()}
            | {:sort, sort_options()}
          )

  @typedoc "Keyword list of options for the dots of the chart."
  @type dots_options ::
          list({:radius, number()} | {:color, String.t()} | {:class, nil | String.t()})

  @typedoc "Keyword list of options for the line of the chart."
  @type line_options ::
          list(
            {:width, number()}
            | {:color, String.t()}
            | {:dasharray, String.t()}
            | {:class, nil | String.t()}
          )

  @typedoc "Keyword list of options for the area under the line of the chart."
  @type area_options :: list({:color, String.t()} | {:class, nil | String.t()})

  @typedoc "Keyword list of options for a marker of the chart."
  @type marker_options ::
          list(
            {:fill_color, String.t()}
            | {:stroke_color, String.t()}
            | {:stroke_width, number()}
            | {:stroke_dasharray, String.t()}
            | {:class, nil | String.t()}
          )

  @typedoc "Keyword list of options for a reference line."
  @type ref_line_options ::
          list({:width, number()} | {:color, String.t()} | {:class, nil | String.t()})

  @typedoc "Keyword list of options for the x window."
  @type window_options :: list({:min, :auto | x()} | {:max, :auto | x()})

  @typedoc "Keyword list of options for the placeholder."
  @type placeholder_options :: list({:class, String.t()})

  @typedoc false
  @type opt_padding :: %{top: number(), right: number(), bottom: number(), left: number()}

  @typedoc false
  @type opts :: %{
          width: number(),
          height: number(),
          padding: opt_padding(),
          smoothing: float(),
          class: nil | String.t(),
          sort: sort_options(),
          dots: nil | map(),
          line: nil | map(),
          area: nil | map(),
          placeholder: nil | map()
        }

  @typedoc false
  @type ref_lines :: %{optional(ref_line()) => ReferenceLine.t()}

  @typedoc false
  @type window :: %{min: :auto | x(), max: :auto | x()}

  @typedoc false
  @type t :: %__MODULE__{
          datapoints: datapoints(),
          options: opts(),
          markers: list(Marker.t()),
          ref_lines: ref_lines(),
          window: window()
        }
  @enforce_keys [:datapoints, :options, :markers, :ref_lines, :window]
  defstruct [:datapoints, :options, :markers, :ref_lines, :window]

  @doc ~S"""
  Create a new sparkline struct with the given datapoints and options.

  If neither `SparklineSvg.show_dots/2`, `SparklineSvg.show_line/2`, nor `SparklineSvg.show_area/2`
  are called, the rendered chart will be an empty SVG document.

  List of available options can be found [here](`m:SparklineSvg#module-available-options`).

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
    precision: 3,
    class: nil,
    sort: :asc
  ]

  @doc since: "0.1.0"
  @spec new(datapoints()) :: t()
  @spec new(datapoints(), options()) :: t()
  def new(datapoints, options \\ []) do
    options =
      @default_opts
      |> Keyword.merge(options)
      |> Map.new()
      |> Map.update!(:padding, &expand_padding/1)
      |> Map.merge(%{dots: nil, line: nil, area: nil, placeholder: nil})

    %SparklineSvg{
      datapoints: datapoints,
      options: options,
      markers: [],
      ref_lines: %{},
      window: %{min: :auto, max: :auto}
    }
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given dots options.

  Calling this function multiple times will override the previous dots options. If no options are
  given, the dots will be shown with the default options.

  List of available options can be found [here](`m:SparklineSvg#module-dots-options`).

  ## Examples

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_dots()
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" r="1" fill="black" /><circle cx="198.0" cy="2.0" r="1" fill="black" /></svg>'

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_dots(radius: 0.5, color: "red")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" r="0.5" fill="red" /><circle cx="198.0" cy="2.0" r="0.5" fill="red" /></svg>'

  """

  @default_dots_opts [radius: 1, color: "black", class: nil]

  @doc since: "0.1.0"
  @spec show_dots(t()) :: t()
  @spec show_dots(t(), dots_options()) :: t()
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

  List of available options can be found [here](`m:SparklineSvg#module-line-options`).

  ## Examples

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_line()
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_line(width: 0.1, color: "green")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="green" stroke-width="0.1" /></svg>'

  """

  @default_line_opts [width: 0.25, color: "black", dasharray: "", class: nil]

  @doc since: "0.1.0"
  @spec show_line(t()) :: t()
  @spec show_line(t(), line_options()) :: t()
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

  List of available options can be found [here](`m:SparklineSvg#module-area-options`).

  ## Examples

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_area()
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" fill="rgba(0, 0, 0, 0.1)" stroke="none" /></svg>'

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_area(color: "rgba(0, 255, 255, 0.2)")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" fill="rgba(0, 255, 255, 0.2)" stroke="none" /></svg>'

  """

  @default_area_opts [color: "rgba(0, 0, 0, 0.1)", class: nil]

  @doc since: "0.1.0"
  @spec show_area(t()) :: t()
  @spec show_area(t(), area_options()) :: t()
  def show_area(sparkline, options \\ []) do
    area_options =
      @default_area_opts
      |> Keyword.merge(options)
      |> Map.new()

    %SparklineSvg{sparkline | options: %{sparkline.options | area: area_options}}
  end

  @doc ~S"""
  Add one reference line to a sparkline struct with the given options.

  Available reference lines are `:max`, `:min`, `:avg`, and `:median`.

  Reference lines on an empty chart won't be rendered.

  List of available options can be found [here](`m:SparklineSvg#module-reference-line-options`).

  ## Examples

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_ref_line(:max)
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><line x1="2" y1="2.0" x2="198" y2="2.0" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'

      iex> chart = SparklineSvg.new([1, 2]) |> SparklineSvg.show_ref_line(:avg, color: "red")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><line x1="2" y1="25.0" x2="198" y2="25.0" fill="none" stroke="red" stroke-width="0.25" /></svg>'

  """

  @doc since: "0.2.0"
  @spec show_ref_line(t(), ref_line()) :: t()
  @spec show_ref_line(t(), ref_line(), ref_line_options()) :: t()
  def show_ref_line(sparkline, type, options \\ []) do
    ref_line = ReferenceLine.new(type, options)
    ref_lines = Map.put(sparkline.ref_lines, type, ref_line)

    %SparklineSvg{sparkline | ref_lines: ref_lines}
  end

  @doc ~S"""
  Set the placeholder of a sparkline struct with the given options.

  The placeholder will only be shown for an empty chart. Without this function, a chart with no
  datapoints will be an empty SVG document.

  List of available options can be found [here](`m:SparklineSvg#module-placeholder-options`).

  ## Examples

      iex> chart = SparklineSvg.new([]) |> SparklineSvg.set_placeholder("No data")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><text x="50%" y="50%" text-anchor="middle">No data</text></svg>'

      iex> chart = SparklineSvg.new([]) |> SparklineSvg.set_placeholder("No data", class: "placeholder")
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><text x="50%" y="50%" text-anchor="middle" class="placeholder">No data</text></svg>'

  """

  @default_placeholder_opts [class: nil]

  @doc since: "0.x.0"
  @spec set_placeholder(t(), String.t()) :: t()
  @spec set_placeholder(t(), String.t(), placeholder_options()) :: t()
  def set_placeholder(sparkline, content, options \\ []) do
    placeholder_options =
      @default_placeholder_opts
      |> Keyword.merge(content: content)
      |> Keyword.merge(options)
      |> Map.new()

    %SparklineSvg{sparkline | options: %{sparkline.options | placeholder: placeholder_options}}
  end

  @doc ~S"""
  Set the x window of a sparkline struct with the given options.

  The window is automatically calculated based on the datapoints. If you want to set a custom
  window, use this function.

  Datapoints outside the window will be removed before rendering and reference lines computations.

  When using this function with a list of numbers as datapoints, the min window value and the max
  window must be interpreted as the index of the list. Negative values are allowed.

  List of available options can be found [here](`m:SparklineSvg#module-window-options`).

  ## Examples

      iex> chart = SparklineSvg.new([1, 2, 3, 4]) |> SparklineSvg.show_line() |> SparklineSvg.set_x_window(min: 1, max: 2)
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

      iex> chart = SparklineSvg.new([1, 2, 3]) |> SparklineSvg.show_line() |> SparklineSvg.set_x_window(min: -1, max: 3)
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M51.0,48.0C58.35,44.55 85.3,31.9 100.0,25.0C114.7,18.1 141.65,5.45 149.0,2.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

      iex> now = DateTime.utc_now()
      iex> chart =
      ...>   [{now, 2}, {DateTime.add(now, 1), 3}]
      ...>   |> SparklineSvg.new()
      ...>   |> SparklineSvg.show_line()
      ...>   |> SparklineSvg.set_x_window(min: DateTime.add(now, -1))
      iex> SparklineSvg.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M100.0,48.0C114.7,41.1 183.3,8.9 198.0,2.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

  """

  @default_window_opts [min: :auto, max: :auto]

  @doc since: "0.5.0"
  @spec set_x_window(t()) :: t()
  @spec set_x_window(t(), window_options()) :: t()
  def set_x_window(sparkline, options \\ []) do
    window =
      @default_window_opts
      |> Keyword.merge(options)
      |> Map.new()

    %SparklineSvg{sparkline | window: window}
  end

  @doc ~S"""
  Add one or many markers to a sparkline struct with the given options.

  When calling this function with a list of markers, the options will be applied to all the markers.

  If you want to apply different options to different markers, you can call this function multiple
  times with a single marker and the desired options.

  Markers are not used to calculate the boudaries of the chart. If you set a marker outside the
  range of the chart, it will be rendered but won't be visible.

  List of available options can be found [here](`m:SparklineSvg#module-marker-options`).

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

  @doc since: "0.1.0"
  @spec add_marker(t(), marker() | markers()) :: t()
  @spec add_marker(t(), marker() | markers(), marker_options()) :: t()
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

  @doc since: "0.1.0"
  @spec to_svg(t()) :: {:ok, String.t()} | {:error, atom()}
  def to_svg(sparkline) do
    case compute(sparkline) do
      {:ok, sparkline} ->
        sparkline =
          sparkline
          |> Draw.chart()
          |> IO.iodata_to_binary()

        {:ok, sparkline}

      {:error, reason} ->
        {:error, reason}
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

  @doc since: "0.1.0"
  @spec to_svg!(t()) :: String.t()
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

  @doc since: "0.1.0"
  @spec as_data_uri(String.t()) :: String.t()
  def as_data_uri(svg) when is_binary(svg) do
    ["data:image/svg+xml;base64", Base.encode64(svg)] |> Enum.join(",")
  end

  # Functions for test only

  if Mix.env() == :test do
    @doc ~S"""
    Take a sparkline struct and return a new sparkline computed and checked struct but without
    rendering it to an SVG document.
    """

    @doc since: "0.2.0"
    @spec dry_run(t()) :: {:ok, t()} | {:error, atom()}
    def dry_run(sparkline), do: compute(sparkline)
  end

  # Private functions

  @spec compute(t()) :: {:ok, t()} | {:error, atom()}
  defp compute(sparkline) do
    %{
      datapoints: datapoints,
      markers: markers,
      ref_lines: ref_lines,
      window: window,
      options: %{width: width, height: height, padding: padding, sort: sort}
    } = sparkline

    with :ok <- check_x_dimension(width, padding),
         :ok <- check_y_dimension(height, padding),
         {:ok, datapoints, window, type} <- Datapoint.clean(datapoints, window, sort),
         {:ok, markers} <- Marker.clean(markers, type),
         {:ok, ref_lines} <- ReferenceLine.clean(ref_lines) do
      sparkline =
        %SparklineSvg{
          sparkline
          | datapoints: datapoints,
            markers: markers,
            ref_lines: ref_lines,
            window: window
        }
        |> Core.compute()

      {:ok, sparkline}
    end
  end

  @spec expand_padding(padding()) :: opt_padding()
  defp expand_padding(padding) when is_list(padding) do
    default = Keyword.get(@default_opts, :padding)

    %{
      top: Keyword.get(padding, :top, default),
      right: Keyword.get(padding, :right, default),
      bottom: Keyword.get(padding, :bottom, default),
      left: Keyword.get(padding, :left, default)
    }
  end

  defp expand_padding(padding) do
    %{top: padding, right: padding, bottom: padding, left: padding}
  end

  @spec check_x_dimension(number(), opt_padding()) :: :ok | {:error, atom()}
  defp check_x_dimension(width, padding) do
    if width - padding.left - padding.right > 0,
      do: :ok,
      else: {:error, :invalid_dimension}
  end

  @spec check_y_dimension(number(), opt_padding()) :: :ok | {:error, atom()}
  defp check_y_dimension(height, padding) do
    if height - padding.top - padding.bottom > 0,
      do: :ok,
      else: {:error, :invalid_dimension}
  end
end
