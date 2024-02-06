defmodule Sparkline.Draw do
  @moduledoc false

  alias Sparkline.Datapoint

  @spec chart(Sparkline.t()) :: Sparkline.svg()
  def chart(%Sparkline{datapoints: []} = sparkline) do
    %{options: %{width: width, height: height, placeholder: placeholder}} = sparkline

    """
    <svg width="100%" height="100%"
      viewBox="0 0 #{width} #{height}"
      xmlns="http://www.w3.org/2000/svg">
      #{if(placeholder != nil, do: placeholder(placeholder))}
    </svg>
    """
  end

  def chart(%Sparkline{} = sparkline) do
    %{
      datapoints: datapoints,
      options: %{dots: dots_options, line: line_options, area: area_options} = options
    } = sparkline

    """
    <svg width="100%" height="100%"
      viewBox="0 0 #{options.width} #{options.height}"
      xmlns="http://www.w3.org/2000/svg">
      #{if(area_options != nil, do: area(datapoints, options))}
      #{if(line_options != nil, do: line(datapoints, options))}
      #{if(dots_options != nil, do: dots(datapoints, options))}
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

  @spec dots(Datapoint.points(), Sparkline.internal_options()) :: String.t()
  defp dots(datapoints, options) do
    Enum.map_join(datapoints, "", fn %{x: x, y: y} ->
      """
      <circle
        cx="#{format_float(x)}"
        cy="#{format_float(y)}"
        r="#{options.dots.radius}"
        fill="#{options.dots.color}" />
      """
    end)
  end

  @spec line(Datapoint.points(), Sparkline.internal_options()) :: String.t()
  defp line([%{x: x, y: y}], options) do
    left = x - options.width / 10
    right = x + options.width / 10

    """
    <path
      d="M#{left},#{format_float(y)}L#{right},#{format_float(y)}"
      fill="none"
      stroke="#{options.line.color}"
      stroke-width="#{options.line.width}" />
    """
  end

  defp line(datapoints, options) do
    """
    <path
      d="#{compute_curve(datapoints, options)}"
      fill="none"
      stroke="#{options.line.color}"
      stroke-width="#{options.line.width}" />
    """
  end

  @spec area(Datapoint.points(), Sparkline.internal_options()) :: String.t()
  defp area([_points], _options), do: ""

  defp area(datapoints, options) do
    # Extract the x value of the first datapoint to know where to finish the area.
    [%{x: x, y: _y} | _] = datapoints

    """
    <path
      d="#{[compute_curve(datapoints, options), "V", "#{options.height}", "H", "#{x}", "Z"]}"
      fill="#{options.area.color}"
      stroke="none" />
    """
  end

  @spec compute_curve(Datapoint.points(), Sparkline.internal_options()) :: iolist()
  defp compute_curve([%{x: x, y: y} = curr | rest], options) do
    ["M#{tuple_to_string({x, y})}"]
    |> compute_curve(rest, curr, curr, options)
  end

  @spec compute_curve(
          iolist(),
          Datapoint.points(),
          Datapoint.point(),
          Datapoint.point(),
          Sparkline.internal_options()
        ) :: iolist()
  defp compute_curve(acc, [curr | [next | _] = rest], prev2, prev1, options) do
    acc
    |> curve_command(prev2, prev1, curr, next, options)
    |> compute_curve(rest, prev1, curr, options)
  end

  defp compute_curve(acc, [curr], prev2, prev1, options) do
    curve_command(acc, prev2, prev1, curr, curr, options)
  end

  @spec curve_command(
          iolist(),
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          Sparkline.internal_options()
        ) :: iolist()
  defp curve_command(acc, prev2, prev1, curr, next, options) do
    cp1 = calculate_control_point(prev1, prev2, curr, :left, options)
    cp2 = calculate_control_point(curr, prev1, next, :right, options)
    currrent = {curr.x, curr.y}

    [acc, "C", tuple_to_string(cp1), " ", tuple_to_string(cp2), " ", tuple_to_string(currrent)]
  end

  @spec calculate_control_point(
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          atom(),
          Sparkline.internal_options()
        ) :: {number(), number()}
  defp calculate_control_point(curr, prev, next, direction, options) do
    {length, angle} = calculate_line(prev, next)

    angle = if direction == :right, do: angle + :math.pi(), else: angle
    length = length * options.smoothing

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
