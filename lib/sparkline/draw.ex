defmodule Sparkline.Draw do
  @moduledoc false

  alias Sparkline.Datapoint

  @spec chart(Sparkline.t()) :: Sparkline.svg()
  def chart(%Sparkline{datapoints: []} = sparkline) do
    placeholder = Keyword.get(sparkline.options, :placeholder)

    """
    <svg width="100%" height="100%"
      viewBox="0 0 #{Keyword.get(sparkline.options, :width)} #{Keyword.get(sparkline.options, :height)}"
      xmlns="http://www.w3.org/2000/svg">
      #{if(placeholder != nil, do: placeholder(placeholder))}
    </svg>
    """
  end

  def chart(%Sparkline{} = sparkline) do
    %{
      datapoints: datapoints,
      options: options,
      dots_options: dots_options,
      line_options: line_options,
      area_options: area_options
    } = sparkline

    """
    <svg width="100%" height="100%"
      viewBox="0 0 #{Keyword.get(options, :width)} #{Keyword.get(options, :height)}"
      xmlns="http://www.w3.org/2000/svg">
      #{if(area_options != nil, do: area(datapoints, options, line_options, area_options))}
      #{if(line_options != nil, do: line(datapoints, options, line_options))}
      #{if(dots_options != nil, do: dots(datapoints, dots_options))}
    </svg>
    """
  end

  @spec placeholder(String.t()) :: String.t()
  defp placeholder(placeholder) do
    """
    <text x="50%" y="50%" text-anchor="middle">
      #{placeholder}
    </text>
    """
  end

  @spec dots(Datapoint.points(), Sparkline.dots_options()) :: String.t()
  defp dots(datapoints, dots_options) do
    Enum.map_join(datapoints, "", fn %{x: x, y: y} ->
      """
      <circle
        cx="#{format_float(x)}"
        cy="#{format_float(y)}"
        r="#{Keyword.get(dots_options, :radius)}"
        fill="#{Keyword.get(dots_options, :color)}" />
      """
    end)
  end

  @spec line(Datapoint.points(), Sparkline.options(), Sparkline.line_options()) :: String.t()
  defp line([%{x: x, y: y}], options, line_options) do
    left = x - Keyword.get(options, :width) / 10
    right = x + Keyword.get(options, :width) / 10

    """
    <path
      d="M#{left},#{format_float(y)}L#{right},#{format_float(y)}"
      fill="none"
      stroke="#{Keyword.get(line_options, :color)}"
      stroke-width="#{Keyword.get(line_options, :width)}" />
    """
  end

  defp line(datapoints, _options, line_options) do
    """
    <path
      d="#{compute_curve(datapoints, line_options)}"
      fill="none"
      stroke="#{Keyword.get(line_options, :color)}"
      stroke-width="#{Keyword.get(line_options, :width)}" />
    """
  end

  @spec area(
          Datapoint.points(),
          Sparkline.options(),
          Sparkline.line_options(),
          Sparkline.area_options()
        ) :: String.t()
  defp area([_points], _options, _line_options, _area_options) do
    ""
  end

  defp area(datapoints, options, line_options, area_options) do
    # Extract the x value of the first datapoint to know where to finish the area.
    [%{x: x, y: _y} | _] = datapoints

    """
    <path
      d="#{[compute_curve(datapoints, line_options), "V", "#{Keyword.get(options, :height)}", "H", "#{x}", "Z"]}"
      fill="#{Keyword.get(area_options, :color)}"
      stroke="none" />
    """
  end

  @spec compute_curve(Datapoint.points(), Sparkline.line_options()) :: iolist()
  defp compute_curve([%{x: x, y: y} = curr | rest], line_options) do
    ["M#{tuple_to_string({x, y})}"]
    |> compute_curve(rest, curr, curr, line_options)
  end

  @spec compute_curve(
          iolist(),
          Datapoint.points(),
          Datapoint.point(),
          Datapoint.point(),
          Sparkline.line_options()
        ) :: iolist()
  defp compute_curve(acc, [curr | [next | _] = rest], prev2, prev1, line_options) do
    acc
    |> curve_command(prev2, prev1, curr, next, line_options)
    |> compute_curve(rest, prev1, curr, line_options)
  end

  defp compute_curve(acc, [curr], prev2, prev1, line_options) do
    curve_command(acc, prev2, prev1, curr, curr, line_options)
  end

  @spec curve_command(
          iolist(),
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          Sparkline.line_options()
        ) :: iolist()
  defp curve_command(acc, prev2, prev1, curr, next, line_options) do
    cp1 = calculate_control_point(prev1, prev2, curr, :left, line_options)
    cp2 = calculate_control_point(curr, prev1, next, :right, line_options)
    currrent = {curr.x, curr.y}

    [acc, "C", tuple_to_string(cp1), " ", tuple_to_string(cp2), " ", tuple_to_string(currrent)]
  end

  @spec calculate_control_point(
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          atom(),
          Sparkline.line_options()
        ) ::
          {number(), number()}
  defp calculate_control_point(curr, prev, next, direction, line_options) do
    smoothing = Keyword.get(line_options, :smoothing)

    {length, angle} = calculate_line(prev, next)

    angle = if direction == :right, do: angle + :math.pi(), else: angle
    length = length * smoothing

    {
      curr.x + :math.cos(angle) * length,
      curr.y + :math.sin(angle) * length
    }
  end

  @spec calculate_line(Datapoint.point(), Datapoint.point()) :: {number(), number()}
  defp calculate_line(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    length_x = x2 - x1
    length_y = y2 - y1

    {
      :math.sqrt(:math.pow(length_x, 2) + :math.pow(length_y, 2)),
      :math.atan2(length_y, length_x)
    }
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
