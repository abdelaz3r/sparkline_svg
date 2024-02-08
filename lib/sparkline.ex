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
  alias Sparkline.Marker

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
            | {:stroke_width, String.t()}
            | {:class, nil | String.t()}
          )

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
  @type t :: %__MODULE__{
          datapoints: datapoints(),
          options: opts(),
          markers: list(Marker.t())
        }
  @enforce_keys [:datapoints, :options, :markers]
  defstruct [:datapoints, :options, :markers]

  @doc ~S"""
  Create a new sparkline struct with the given datapoints and options.

  If neither `Sparkline.show_dots/2`, `Sparkline.show_line/2`, nor `Sparkline.show_area/2` are
  called, the rendered chart will be an empty SVG document.

  ## Examples

      iex> chart = Sparkline.new([1, 2])
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"></svg>'

      iex> chart = Sparkline.new([1, 2], width: 240, height: 80)
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 240 80" xmlns="http://www.w3.org/2000/svg"></svg>'

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

    %Sparkline{datapoints: datapoints, options: options, markers: []}
  end

  @doc ~S"""
  Take a sparkline struct and return a new sparkline struct with the given dots options.

  Calling this function multiple times will override the previous dots options. If no options are
  given, the dots will be shown with the default options.

  ## Examples

      iex> chart = Sparkline.new([1, 2]) |> Sparkline.show_dots()
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><circle cx="6.0" cy="94.0" r="1" fill="black" /><circle cx="194.0" cy="6.0" r="1" fill="black" /></svg>'

      iex> chart = Sparkline.new([1, 2]) |> Sparkline.show_dots(radius: 0.5, color: "red")
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><circle cx="6.0" cy="94.0" r="0.5" fill="red" /><circle cx="194.0" cy="6.0" r="0.5" fill="red" /></svg>'

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
  Take a sparkline struct and return a new sparkline struct with the given line options.

  Calling this function multiple times will override the previous line options. If no options are
  given, the line will be shown with the default options.

  ## Examples

      iex> chart = Sparkline.new([1, 2]) |> Sparkline.show_line()
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

      iex> chart = Sparkline.new([1, 2]) |> Sparkline.show_line(width: 0.1, color: "green")
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0" fill="none" stroke="green" stroke-width="0.1" /></svg>'

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
  Take a sparkline struct and return a new sparkline struct with the given area options.

  Calling this function multiple times will override the previous area options. If no options are
  given, the area will be shown with the default options.

  ## Examples

      iex> chart = Sparkline.new([1, 2]) |> Sparkline.show_area()
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0V100H6.0Z" fill="rgba(0, 0, 0, 0.2)" stroke="none" /></svg>'

      iex> chart = Sparkline.new([1, 2]) |> Sparkline.show_area(color: "rgba(0, 255, 255, 0.2)")
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0V100H6.0Z" fill="rgba(0, 255, 255, 0.2)" stroke="none" /></svg>'

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
  A one or many markers to a sparkline struct with the given options.

  When calling this function with a list of markers, the options will be applied to all the markers.

  If you want to apply different options to different markers, you can call this function multiple
  times with a single marker and the desired options.

  Markers are not used to calculate the boudaries of the chart. If you set a marker outside the range
  of the chart, it will be rendered but won't be visible.

  ## Examples

      iex> chart = Sparkline.new([1, 3]) |> Sparkline.add_marker(2)
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M382.0,0.0V100" fill="none" stroke="red" stroke-width="0.25" /></svg>'

      iex> chart = Sparkline.new([1, 3]) |> Sparkline.add_marker({2.1, 2.4})
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><rect x="400.8" y="-0.25" width="56.4" height="100.5" fill="rgba(255, 0, 0, 0.2)" stroke="red" stroke-width="0.25" /></svg>'

      iex> chart = Sparkline.new([1, 3]) |> Sparkline.add_marker([2.2, 2.5])
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M476.0,0.0V100" fill="none" stroke="red" stroke-width="0.25" /><path d="M419.6,0.0V100" fill="none" stroke="red" stroke-width="0.25" /></svg>'

      iex> chart = Sparkline.new([1, 3]) |> Sparkline.add_marker(2, stroke_color: "rgba(0, 255, 0, 0.2)")
      iex> Sparkline.to_svg!(chart)
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M382.0,0.0V100" fill="none" stroke="rgba(0, 255, 0, 0.2)" stroke-width="0.25" /></svg>'

  """
  @spec add_marker(Sparkline.t(), marker()) :: Sparkline.t()
  @spec add_marker(Sparkline.t(), marker() | list(marker()), marker_options()) :: Sparkline.t()
  def add_marker(sparkline, markers, options \\ [])

  def add_marker(sparkline, markers, options) when is_list(markers) do
    markers = Enum.map(markers, fn marker -> Marker.new(marker, options) end)
    %Sparkline{sparkline | markers: markers ++ sparkline.markers}
  end

  def add_marker(sparkline, marker, options) do
    add_marker(sparkline, [marker], options)
  end

  @doc ~S"""
  Return a valid SVG document from a sparkline struct.

  ## Examples

      iex> Sparkline.new([1, 2]) |> Sparkline.to_svg()
      {:ok, ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"></svg>'}

      iex> Sparkline.new([1, 2], width: 10, padding: 10) |> Sparkline.to_svg()
      {:error, :invalid_dimension}

  """
  @spec to_svg(Sparkline.t()) :: {:ok, String.t()} | {:error, atom()}
  def to_svg(sparkline) do
    %{width: width, height: height, padding: padding} = sparkline.options

    with :ok <- check_dimension(width, padding),
         :ok <- check_dimension(height, padding),
         {:ok, datapoints, type} <- Datapoint.clean(sparkline.datapoints),
         {:ok, markers} <- Marker.clean(sparkline.markers, type) do
      sparkline =
        if Enum.empty?(datapoints) do
          sparkline
        else
          {min_max_x, min_max_y} = Datapoint.get_min_max(datapoints)

          datapoints = Datapoint.resize(datapoints, min_max_x, min_max_y, sparkline.options)
          markers = Marker.resize(markers, min_max_x, sparkline.options)

          %Sparkline{sparkline | datapoints: datapoints, markers: markers}
        end

      svg =
        sparkline
        |> Draw.chart()
        |> :erlang.iolist_to_binary()

      {:ok, svg}
    end
  end

  @doc ~S"""
  Return a valid SVG document from a sparkline struct.

  ## Examples

      iex> Sparkline.new([1, 2]) |> Sparkline.to_svg!()
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"></svg>'

      iex> Sparkline.new([1, 2], width: 10, padding: 10) |> Sparkline.to_svg!()
      ** (Sparkline.Error) invalid_dimension

  """
  @spec to_svg!(Sparkline.t()) :: String.t()
  def to_svg!(sparkline) do
    case to_svg(sparkline) do
      {:ok, svg} -> svg
      {:error, reason} -> raise(Sparkline.Error, Atom.to_string(reason))
    end
  end

  @doc ~S"""
  Convert a svg string into a Base64 string to be used, for example, as a background-image.

  Note that using SVG as a background-image has some limitations. For example, CSS Selectors in a
  host document cannot query an SVG document that is embedded as an external resource as opposed to
  being inlined with the host document markup.

  ## Examples

      iex> svg = Sparkline.new([1, 2]) |> Sparkline.to_svg!()
      iex> Sparkline.as_data_uri(svg)
      "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiB2aWV3Qm94PSIwIDAgMjAwIDEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48L3N2Zz4="

  """
  @spec as_data_uri(String.t()) :: String.t()
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
