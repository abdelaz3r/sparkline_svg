defmodule SimpleCharts.Line do
  @moduledoc """
  Documentation for `SimpleCharts.Line`.
  """

  @typedoc "Data point."
  @type datapoint :: {DateTime.t() | Time.t() | integer(), number()}

  @typedoc "Data points."
  @type datapoints :: list(datapoint())

  @typedoc "Option."
  @type option ::
          {:width, non_neg_integer()}
          | {:height, non_neg_integer()}
          | {:padding, non_neg_integer()}
          | {:dots?, boolean()}
          | {:dot_radius, number()}
          | {:dot_color, String.t()}
          | {:line?, boolean()}
          | {:line_width, number()}
          | {:line_color, String.t()}
          | {:line_smoothing, float()}
          | {:area?, boolean()}
          | {:area_color, String.t()}

  @typedoc "Options."
  @type options :: list(option())

  @doc """
  Return a valid SVG document representing a line chart with the given datapoints.

  ## Examples

      iex> SimpleCharts.Line.to_svg([{1, 1}, {2, 2}, {3, 3}])
      svg_string

      iex> SimpleCharts.Line.to_svg([{1, 1}, {2, 2}, {3, 3}], width: 240, height: 80)
      svg_string

  """
  @spec to_svg(datapoints :: datapoints()) :: {:ok, String.t()} | {:error, atom()}
  def to_svg(datapoints), do: to_svg(datapoints, [])

  @spec to_svg(datapoints :: datapoints(), options()) :: {:ok, String.t()} | {:error, atom()}
  def to_svg([], _options) do
    {:error, :empty_datapoints}
  end

  def to_svg(datapoints, options) do
    options = default_options(options)

    width = Keyword.get(options, :width)
    height = Keyword.get(options, :height)
    padding = Keyword.get(options, :padding)

    # TODO: check that width - 2 * padding > 0 and height - 2 * padding > 0
    # TODO: check that max_time - min_time != 0 and max_value - min_value != 0

    datapoints =
      Enum.map(datapoints, fn
        {%Time{} = x, y} ->
          {seconds, _milliseconds} = Time.to_seconds_after_midnight(x)
          {seconds, y}

        {%DateTime{} = x, y} ->
          {DateTime.to_unix(x), y}

        {x, y} ->
          {x, y}
      end)

    {{min_time, _}, {max_time, _}} = Enum.min_max_by(datapoints, fn {x, _} -> x end)
    {{_, min_value}, {_, max_value}} = Enum.min_max_by(datapoints, fn {_, y} -> y end)

    datapoints =
      datapoints
      |> Enum.sort_by(fn {x, _} -> x end)
      |> Enum.map(fn {x, y} ->
        %{
          x: (x - min_time) / (max_time - min_time) * (width - padding * 2) + padding,
          y: height - (y - min_value) / (max_value - min_value) * (height - padding * 2) - padding
        }
      end)

    {:ok,
     """
     <svg width="auto" height="auto" viewBox="0 0 #{width} #{height}" xmlns="http://www.w3.org/2000/svg">
       #{if(Keyword.get(options, :area?), do: draw_area(datapoints, options))}
       #{if(Keyword.get(options, :line?), do: draw_line(datapoints, options))}
       #{if(Keyword.get(options, :dots?), do: draw_dots(datapoints, options))}
     </svg>
     """}
  end

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

  defp draw_line(datapoints, options) do
    """
    <path
      d="#{compute_curve(datapoints, options)}"
      fill="none"
      stroke="#{Keyword.get(options, :line_color)}"
      stroke-width="#{Keyword.get(options, :line_width)}" />
    """
  end

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

  defp compute_curve([%{x: x, y: y} = curr | points], options) do
    "M #{point_to_string({x, y})} "
    |> compute_curve(points, curr, curr, options)
  end

  defp compute_curve(acc, [curr | [next | _] = points], prev2, prev1, options) do
    acc
    |> curve_command(prev2, prev1, curr, next, options)
    |> compute_curve(points, prev1, curr, options)
  end

  defp compute_curve(acc, [curr | []], prev2, prev1, options) do
    curve_command(acc, prev2, prev1, curr, curr, options)
  end

  defp curve_command(acc, prev2, prev1, curr, next, options) do
    cp1 = calculate_control_point(prev1, prev2, curr, :left, options)
    cp2 = calculate_control_point(curr, prev1, next, :right, options)

    "#{acc} C #{point_to_string(cp1)} #{point_to_string(cp2)} #{point_to_string({curr.x, curr.y})}"
  end

  defp calculate_control_point(curr, prev, next, direction, options) do
    smoothing = Keyword.get(options, :line_smoothing, 0.2)

    {length, angle} = calculate_line(prev, next)

    angle = if direction == :right, do: angle + :math.pi(), else: angle
    length = length * smoothing

    {
      curr.x + :math.cos(angle) * length,
      curr.y + :math.sin(angle) * length
    }
  end

  defp calculate_line(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    length_x = x2 - x1
    length_y = y2 - y1

    {
      :math.sqrt(:math.pow(length_x, 2) + :math.pow(length_y, 2)),
      :math.atan2(length_y, length_x)
    }
  end

  # Helper functions

  defp default_options(options) do
    options
    |> Keyword.put_new(:width, 200)
    |> Keyword.put_new(:height, 100)
    |> Keyword.put_new(:padding, 6)
    |> Keyword.put_new(:dots?, true)
    |> Keyword.put_new(:dot_radius, 1)
    |> Keyword.put_new(:dot_color, "white")
    |> Keyword.put_new(:line?, true)
    |> Keyword.put_new(:line_width, 0.25)
    |> Keyword.put_new(:line_color, "white")
    |> Keyword.put_new(:area?, false)
    |> Keyword.put_new(:area_color, "black")
  end

  defp point_to_string({x, y}) do
    "#{format_float(x)},#{format_float(y)}"
  end

  defp format_float(float) when is_float(float) do
    Float.round(float, 3)
  end
end
