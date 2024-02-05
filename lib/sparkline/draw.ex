defmodule Sparkline.Draw do
  @moduledoc false

  alias Sparkline.Core

  @spec chart(Core.points(), Sparkline.options()) :: Sparkline.svg()
  def chart([], options) do
    """
    <svg width="100%" height="100%"
      viewBox="0 0 #{Keyword.get(options, :width)} #{Keyword.get(options, :height)}"
      xmlns="http://www.w3.org/2000/svg">
      <text x="50%" y="50%" text-anchor="middle">
        #{Keyword.get(options, :placeholder)}
      </text>
    </svg>
    """
  end

  def chart([%{x: x, y: y}], options) do
    left = Keyword.get(options, :padding)
    right = Keyword.get(options, :width) - 2 * Keyword.get(options, :padding)

    """
    <svg width="100%" height="100%"
      viewBox="0 0 #{Keyword.get(options, :width)} #{Keyword.get(options, :height)}"
      xmlns="http://www.w3.org/2000/svg">
      <path
        d="M#{left},#{format_float(y)}L#{right},#{format_float(y)}"
        fill="none"
        stroke="#{Keyword.get(options, :line_color)}"
        stroke-width="#{Keyword.get(options, :line_width)}" />
      <circle
        cx="#{format_float(x)}"
        cy="#{format_float(y)}"
        r="#{Keyword.get(options, :dot_radius)}"
        fill="#{Keyword.get(options, :dot_color)}" />
    </svg>
    """
  end

  def chart(datapoints, options) do
    """
    <svg width="100%" height="100%"
      viewBox="0 0 #{Keyword.get(options, :width)} #{Keyword.get(options, :height)}"
      xmlns="http://www.w3.org/2000/svg">
      #{if(Keyword.get(options, :show_area), do: area(datapoints, options))}
      #{if(Keyword.get(options, :show_line), do: line(datapoints, options))}
      #{if(Keyword.get(options, :show_dot), do: dots(datapoints, options))}
    </svg>
    """
  end

  @spec dots(Core.points(), Sparkline.options()) :: String.t()
  defp dots(datapoints, options) do
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

  @spec line(Core.points(), Sparkline.options()) :: String.t()
  defp line(datapoints, options) do
    """
    <path
      d="#{compute_curve(datapoints, options)}"
      fill="none"
      stroke="#{Keyword.get(options, :line_color)}"
      stroke-width="#{Keyword.get(options, :line_width)}" />
    """
  end

  @spec area(Core.points(), Sparkline.options()) :: String.t()
  defp area(datapoints, options) do
    # Extract the x value of the first datapoint to know where to finish the area.
    [%{x: x, y: _y} | _] = datapoints

    """
    <path
      d="#{[compute_curve(datapoints, options), "V", "#{Keyword.get(options, :height)}", "H", "#{x}", "Z"]}"
      fill="#{Keyword.get(options, :area_color)}"
      stroke="none" />
    """
  end

  @spec compute_curve(Core.points(), Sparkline.options()) :: iolist()
  defp compute_curve([%{x: x, y: y} = curr | rest], options) do
    ["M#{tuple_to_string({x, y})}"]
    |> compute_curve(rest, curr, curr, options)
  end

  @spec compute_curve(
          iolist(),
          Core.points(),
          Core.point(),
          Core.point(),
          Sparkline.options()
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
          Core.point(),
          Core.point(),
          Core.point(),
          Core.point(),
          Sparkline.options()
        ) :: iolist()
  defp curve_command(acc, prev2, prev1, curr, next, options) do
    cp1 = calculate_control_point(prev1, prev2, curr, :left, options)
    cp2 = calculate_control_point(curr, prev1, next, :right, options)
    currrent = {curr.x, curr.y}

    [acc, "C", tuple_to_string(cp1), " ", tuple_to_string(cp2), " ", tuple_to_string(currrent)]
  end

  @spec calculate_control_point(
          Core.point(),
          Core.point(),
          Core.point(),
          atom(),
          Sparkline.options()
        ) ::
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

  @spec calculate_line(Core.point(), Core.point()) :: {number(), number()}
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
