defmodule SparklineSvg.Draw do
  @moduledoc false

  alias SparklineSvg.Core
  alias SparklineSvg.Marker
  alias SparklineSvg.ReferenceLine

  @spec chart(SparklineSvg.t()) :: iolist()
  def chart(%SparklineSvg{datapoints: []} = sparkline) do
    %{options: %{width: width, height: height, class: class} = options} = sparkline

    [
      ~s'<svg width="100%" height="100%" viewBox="0 0 #{width} #{height}"',
      if(class != nil, do: [~s' class="', class, ~s'"'], else: ""),
      ~s' xmlns="http://www.w3.org/2000/svg">',
      placeholder(options),
      "</svg>"
    ]
  end

  def chart(%SparklineSvg{} = sparkline) do
    %{
      datapoints: datapoints,
      markers: markers,
      ref_lines: ref_lines,
      options: %{width: width, height: height, class: class} = options
    } = sparkline

    [
      ~s'<svg width="100%" height="100%" viewBox="0 0 #{width} #{height}"',
      if(class != nil, do: [~s' class="', class, ~s'"'], else: ""),
      ~s' xmlns="http://www.w3.org/2000/svg">',
      area(datapoints, options),
      line(datapoints, options),
      dots(datapoints, options),
      markers(markers, options),
      ref_lines(ref_lines, options),
      ~s'</svg>'
    ]
  end

  @spec placeholder(SparklineSvg.opts()) :: iolist()
  defp placeholder(%{placeholder: nil}), do: ""

  defp placeholder(options) do
    %{placeholder: %{content: content, class: class}} = options

    [
      ~s'<text x="50%" y="50%" text-anchor="middle"',
      if(class != nil, do: [~s' class="', class, ~s'"'], else: ""),
      ~s'>',
      content,
      ~s'</text>'
    ]
  end

  @spec dots(Core.points(), SparklineSvg.opts()) :: iolist()
  defp dots(_datapoints, %{dots: nil}), do: ""

  defp dots(datapoints, options) do
    %{dots: %{color: color, radius: radius, class: class}} = options

    attrs =
      if class == nil,
        do: [~s'fill="', color, ~s'"'],
        else: [~s'class="', class, ~s'"']

    Enum.map(datapoints, fn {x, y} ->
      [
        ~s'<circle cx="',
        cast(x, options),
        ~s'" cy="',
        cast(y, options),
        ~s'" r="#{radius}" ',
        attrs,
        ~s' />'
      ]
    end)
  end

  @spec line(Core.points(), SparklineSvg.opts()) :: iolist()
  defp line(_datapoints, %{line: nil}), do: ""

  defp line([{x, y}], options) do
    %{line: %{color: color, width: width, dasharray: dasharray, class: class}} = options

    left = x - options.width / 10
    right = x + options.width / 10

    attrs =
      if class == nil do
        dash_attr = if(dasharray != "", do: [~s' stroke-dasharray="', dasharray, ~s'"'], else: [])
        [~s'fill="none" stroke="', color, ~s'" stroke-width="', "#{width}", ~s'"', dash_attr]
      else
        [~s'class="', class, ~s'"']
      end

    path = ["M#{left},", cast(y, options), "L#{right},", cast(y, options)]
    [~s'<path d="', path, ~s'" ', attrs, ~s' />']
  end

  defp line(datapoints, options) do
    %{line: %{color: color, width: width, dasharray: dasharray, class: class}} = options

    attrs =
      if class == nil do
        dash_attr = if(dasharray != "", do: [~s' stroke-dasharray="', dasharray, ~s'"'], else: [])
        [~s'fill="none" stroke="', color, ~s'" stroke-width="', "#{width}", ~s'"', dash_attr]
      else
        [~s'class="', class, ~s'"']
      end

    [~s'<path d="', compute_curve(datapoints, options), ~s'" ', attrs, ~s' />']
  end

  @spec area(Core.points(), SparklineSvg.opts()) :: iolist()
  defp area(_datapoints, %{area: nil}), do: ""
  defp area([_points], _options), do: ""

  defp area(datapoints, options) do
    %{area: %{color: color, class: class}, height: height} = options

    # Extract the x value of the first datapoint to know where to finish the area.
    [{x, _y} | _] = datapoints

    attrs =
      if class == nil,
        do: [~s'fill="', color, ~s'" stroke="none"'],
        else: [~s'class="', class, ~s'"']

    path = [compute_curve(datapoints, options), "V#{height}H#{x}Z"]
    [~s'<path d="', path, ~s'" ', attrs, ~s' />']
  end

  @spec markers(list(Marker.t()), SparklineSvg.opts()) :: iolist()
  defp markers(markers, options) do
    Enum.map(markers, fn marker -> marker(marker, options) end)
  end

  @spec marker(Marker.t(), SparklineSvg.opts()) :: iolist()
  defp marker(%Marker{position: {_x1, _x2}} = marker, options) do
    %{
      position: {x1, x2},
      options: %{fill_color: fill_color, stroke_color: color, stroke_width: width, class: class}
    } = marker

    %{height: height} = options

    attrs =
      if class == nil,
        do: [~s'fill="', fill_color, ~s'" stroke="', color, ~s'" stroke-width="#{width}"'],
        else: [~s'class="', class, ~s'"']

    [
      ~s'<rect x="',
      cast(min(x1, x2), options),
      ~s'" y="#{-width}" width="',
      cast(abs(x2 - x1), options),
      ~s'" height="#{height + 2 * width}" ',
      attrs,
      ~s' />'
    ]
  end

  defp marker(%Marker{position: _x} = marker, options) do
    %{
      position: x,
      options: %{
        stroke_color: color,
        stroke_width: width,
        stroke_dasharray: dasharray,
        class: class
      }
    } = marker

    %{height: height} = options

    attrs =
      if class == nil do
        dash_attr = if(dasharray != "", do: [~s' stroke-dasharray="', dasharray, ~s'"'], else: [])
        [~s'fill="none" stroke="', color, ~s'" stroke-width="', "#{width}", ~s'"', dash_attr]
      else
        [~s'class="', class, ~s'"']
      end

    [~s'<path d="M', cast({x, 0.0}, options), ~s'V#{height}" ', attrs, ~s' />']
  end

  @spec ref_lines(SparklineSvg.ref_lines(), SparklineSvg.opts()) :: iolist()
  defp ref_lines(ref_lines, options) do
    Enum.map(ref_lines, fn {_type, ref_line} -> ref_line(ref_line, options) end)
  end

  @spec ref_line(ReferenceLine.t(), SparklineSvg.opts()) :: iolist()
  defp ref_line(ref_line, options) do
    %{position: y, options: %{color: color, width: width, dasharray: dasharray, class: class}} =
      ref_line

    %{padding: padding, width: graph_width} = options
    y = cast(y, options)

    attrs =
      if class == nil do
        dash_attr = if(dasharray != "", do: [~s' stroke-dasharray="', dasharray, ~s'"'], else: [])
        [~s'fill="none" stroke="', color, ~s'" stroke-width="', "#{width}", ~s'"', dash_attr]
      else
        [~s'class="', class, ~s'"']
      end

    [
      ~s'<line x1="#{padding.left}" y1="#{y}" x2="#{graph_width - padding.right}" y2="#{y}" ',
      attrs,
      ~s' />'
    ]
  end

  @spec compute_curve(Core.points(), SparklineSvg.opts()) :: iolist()
  defp compute_curve([curr | rest], options) do
    ["M#{cast(curr, options)}"]
    |> compute_curve(rest, curr, curr, options)
  end

  @spec compute_curve(
          iolist(),
          Core.points(),
          Core.point(),
          Core.point(),
          SparklineSvg.opts()
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
          SparklineSvg.opts()
        ) :: iolist()
  defp curve_command(acc, prev2, prev1, curr, next, options) do
    cp1 = calculate_control_point(prev1, prev2, curr, :left, options)
    cp2 = calculate_control_point(curr, prev1, next, :right, options)

    [acc, "C", cast(cp1, options), " ", cast(cp2, options), " ", cast(curr, options)]
  end

  @spec calculate_control_point(
          Core.point(),
          Core.point(),
          Core.point(),
          :left | :right,
          SparklineSvg.opts()
        ) :: {number(), number()}
  defp calculate_control_point({x, y}, prev, next, direction, options) do
    {length, angle} = calculate_line(prev, next)

    angle = if direction == :right, do: angle + :math.pi(), else: angle
    length = length * options.smoothing

    {
      x + :math.cos(angle) * length,
      y + :math.sin(angle) * length
    }
  end

  @spec calculate_line(Core.point(), Core.point()) :: {number(), number()}
  defp calculate_line({x1, y1}, {x2, y2}) do
    length_x = x2 - x1
    length_y = y2 - y1

    {
      :math.sqrt(:math.pow(length_x, 2) + :math.pow(length_y, 2)),
      :math.atan2(length_y, length_x)
    }
  end

  @spec cast(number() | {number(), number()}, SparklineSvg.opts()) :: iolist() | String.t()
  defp cast({x, y}, opts) do
    [cast(x, opts), ",", cast(y, opts)]
  end

  defp cast(value, _opts) when is_integer(value) do
    Integer.to_string(value)
  end

  defp cast(value, opts) when is_float(value) do
    value
    |> Float.round(opts.precision)
    |> Float.to_string()
  end
end
