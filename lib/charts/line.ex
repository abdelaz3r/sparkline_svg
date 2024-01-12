defmodule SimpleCharts.Line do
  @moduledoc """
  Documentation for `SimpleCharts.Line`.
  """

  @typedoc "Data point."
  @type datapoint :: {DateTime.t() | Date.t() | Time.t() | integer(), number()}

  @typedoc "Data points."
  @type datapoints :: list(datapoint())

  @typedoc "Option."
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

  @typedoc "Options."
  @type options :: list(option())

  # Default options
  @default_options [
    width: 200,
    height: 100,
    padding: 6,
    show_dot: true,
    dot_radius: 1,
    dot_color: "white",
    show_line: true,
    line_width: 0.25,
    line_color: "white",
    line_smoothing: 0.2,
    show_area: false,
    area_color: "black"
  ]

  defexception [:message]

  @doc """
  Return a valid SVG document representing a line chart with the given datapoints.

  ## Examples

      iex> SimpleCharts.Line.to_svg([{1, 1}, {2, 2}, {3, 3}])
      {:ok, svg_string}

      iex> SimpleCharts.Line.to_svg([{1, 1}, {2, 2}, {3, 3}], width: 240, height: 80)
      {:ok, svg_string}

  """
  @spec to_svg(datapoints()) :: {:ok, SimpleCharts.svg()} | {:error, atom()}
  def to_svg(datapoints), do: to_svg(datapoints, [])

  @spec to_svg(datapoints(), options()) :: {:ok, SimpleCharts.svg()} | {:error, atom()}
  def to_svg([], _options), do: {:error, :empty_datapoints}

  def to_svg(datapoints, options) do
    options = default_options(options)
    padding = Keyword.get(options, :padding)

    with {:ok} <- check_dimension(Keyword.get(options, :width), padding),
         {:ok} <- check_dimension(Keyword.get(options, :height), padding),
         {:ok, datapoints} <- normalize_x(datapoints),
         {:ok, min_max_x, min_max_y} <- compute_min_max(datapoints) do
      datapoints =
        datapoints
        |> compute_datapoints(min_max_x, min_max_y, options)
        |> draw_chart(options)

      {:ok, datapoints}
    end
  end

  @doc """
  Return a valid SVG document representing a line chart with the given datapoints.

  ## Examples

      iex> SimpleCharts.Line.to_svg!([{1, 1}, {2, 2}, {3, 3}])
      svg_string

      iex> SimpleCharts.Line.to_svg!([{1, 1}, {2, 2}, {3, 3}], width: 240, height: 80)
      svg_string

  """
  @spec to_svg!(datapoints()) :: SimpleCharts.svg()
  def to_svg!(datapoints), do: to_svg!(datapoints, [])

  @spec to_svg!(datapoints(), options()) :: SimpleCharts.svg()
  def to_svg!([], _options), do: raise(SimpleCharts.Line, "empty_datapoints")

  def to_svg!(datapoints, options) do
    case to_svg(datapoints, options) do
      {:ok, svg} -> svg
      {:error, reason} -> raise(SimpleCharts.Line, Atom.to_string(reason))
    end
  end

  # Private functions

  @typep point :: %{x: number(), y: number()}
  @typep points :: list(point())
  @typep min_max :: {number(), number()}

  @spec check_dimension(number(), number()) :: {:ok} | {:error, atom()}
  defp check_dimension(length, padding) do
    if length - 2 * padding > 0,
      do: {:ok},
      else: {:error, :invalid_dimension}
  end

  @spec normalize_x(datapoints()) :: {:ok, datapoints()} | {:error, atom()}
  defp normalize_x(datapoints) do
    datapoints =
      Enum.map(datapoints, fn
        {%DateTime{} = datetime, y} ->
          {DateTime.to_unix(datetime), y}

        {%Date{} = date, y} ->
          {:ok, datetime} = DateTime.new(date, ~T[00:00:00])
          {DateTime.to_unix(datetime), y}

        {%Time{} = time, y} ->
          {seconds, _milliseconds} = Time.to_seconds_after_midnight(time)
          {seconds, y}

        {x, y} when is_integer(x) or is_float(x) ->
          {x, y}

        _ ->
          {:error, :invalid_datapoints}
      end)

    if Enum.any?(datapoints, fn {x, _y} -> x == :error end),
      do: {:error, :invalid_datapoints},
      else: {:ok, datapoints}
  end

  @spec compute_min_max(datapoints()) :: {:ok, min_max(), min_max()} | {:error, atom()}
  defp compute_min_max(datapoints) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(datapoints, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(datapoints, fn {_, y} -> y end)

    if max_x - min_x != 0 or max_y - min_y != 0,
      do: {:ok, {min_x, max_x}, {min_y, max_y}},
      else: {:error, :invalid_datapoints}
  end

  @spec compute_datapoints(datapoints(), min_max(), min_max(), options()) :: points()
  defp compute_datapoints(datapoints, {min_x, max_x}, {min_y, max_y}, options) do
    width = Keyword.get(options, :width)
    height = Keyword.get(options, :height)
    padding = Keyword.get(options, :padding)

    datapoints
    |> Enum.sort_by(fn {x, _} -> x end)
    |> Enum.map(fn {x, y} ->
      %{
        x: (x - min_x) / (max_x - min_x) * (width - padding * 2) + padding,
        y: height - (y - min_y) / (max_y - min_y) * (height - padding * 2) - padding
      }
    end)
  end

  @spec draw_chart(points(), options()) :: SimpleCharts.svg()
  defp draw_chart(datapoints, options) do
    chart =
      """
      <svg
        width="auto"
        height="auto"
        viewBox="0 0 #{Keyword.get(options, :width)} #{Keyword.get(options, :height)}"
        xmlns="http://www.w3.org/2000/svg">
        #{if(Keyword.get(options, :show_area), do: draw_area(datapoints, options))}
        #{if(Keyword.get(options, :show_line), do: draw_line(datapoints, options))}
        #{if(Keyword.get(options, :show_dots), do: draw_dots(datapoints, options))}
      </svg>
      """

    Regex.replace(~r/\n\s?/, chart, "")
  end

  @spec draw_dots(points(), options()) :: String.t()
  defp draw_dots(datapoints, options) do
    Enum.map_join(datapoints, "", fn %{x: x, y: y} ->
      """
      <circle
        cx="#{format_float(x)}"
        cy="#{format_float(y)}"
        r="#{Keyword.get(options, :dot_radius)}"
        fill="#{Keyword.get(options, :dot_color)}" />
      """
    end)
  end

  @spec draw_line(points(), options()) :: String.t()
  defp draw_line(datapoints, options) do
    """
    <path
      d="#{compute_curve(datapoints, options)}"
      fill="none"
      stroke="#{Keyword.get(options, :line_color)}"
      stroke-width="#{Keyword.get(options, :line_width)}" />
    """
  end

  @spec draw_area(points(), options()) :: String.t()
  defp draw_area(datapoints, options) do
    # Extract the x value of the first datapoint to know where to finish the area.
    [%{x: x, y: _y} | _] = datapoints

    """
    <path
      d="#{compute_curve(datapoints, options)} V #{Keyword.get(options, :height)} H #{x} Z"
      fill="#{Keyword.get(options, :area_color)}"
      stroke="none" />
    """
  end

  @spec compute_curve(points(), options()) :: iolist()
  defp compute_curve([%{x: x, y: y} = curr | points], options) do
    ["M #{tuple_to_string({x, y})} "]
    |> compute_curve(points, curr, curr, options)
  end

  @spec compute_curve(iolist(), points(), point(), point(), options()) :: iolist()
  defp compute_curve(acc, [curr | [next | _] = points], prev2, prev1, options) do
    acc
    |> curve_command(prev2, prev1, curr, next, options)
    |> compute_curve(points, prev1, curr, options)
  end

  defp compute_curve(acc, [curr | []], prev2, prev1, options) do
    curve_command(acc, prev2, prev1, curr, curr, options)
  end

  @spec curve_command(iolist(), point(), point(), point(), point(), options()) :: iolist()
  defp curve_command(acc, prev2, prev1, curr, next, options) do
    cp1 = calculate_control_point(prev1, prev2, curr, :left, options)
    cp2 = calculate_control_point(curr, prev1, next, :right, options)

    part =
      "C #{tuple_to_string(cp1)} #{tuple_to_string(cp2)} #{tuple_to_string({curr.x, curr.y})}"

    [acc | part]
  end

  @spec calculate_control_point(point(), point(), point(), atom(), options()) ::
          {number(), number()}
  defp calculate_control_point(curr, prev, next, direction, options) do
    smoothing = Keyword.get(options, :line_smoothing)

    {length, angle} = calculate_line(prev, next)

    angle = if direction == :right, do: angle + :math.pi(), else: angle
    length = length * smoothing

    {
      curr.x + :math.cos(angle) * length,
      curr.y + :math.sin(angle) * length
    }
  end

  @spec calculate_line(point(), point()) :: {number(), number()}
  defp calculate_line(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    length_x = x2 - x1
    length_y = y2 - y1

    {
      :math.sqrt(:math.pow(length_x, 2) + :math.pow(length_y, 2)),
      :math.atan2(length_y, length_x)
    }
  end

  # Helper functions

  @spec default_options(options()) :: options()
  defp default_options(options) do
    Keyword.merge(@default_options, options, fn _k, _default, value -> value end)
  end

  @spec tuple_to_string({number(), number()}) :: String.t()
  defp tuple_to_string({x, y}) do
    "#{format_float(x)},#{format_float(y)}"
  end

  @spec format_float(float()) :: float()
  defp format_float(float) when is_float(float) do
    Float.round(float, 3)
  end
end
