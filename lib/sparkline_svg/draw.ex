defmodule SparklineSvg.Draw do
  @moduledoc false

  alias SparklineSvg.Datapoint
  alias SparklineSvg.Marker

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
      ~s'</svg>'
    ]
  end

  @spec placeholder(SparklineSvg.opts()) :: iolist()
  defp placeholder(%{placeholder: nil}), do: ""

  defp placeholder(options) do
    %{placeholder: placeholder, placeholder_class: placeholder_class} = options

    [
      ~s'<text x="50%" y="50%" text-anchor="middle"',
      if(placeholder_class != nil, do: [~s' class="', placeholder_class, ~s'"'], else: ""),
      ~s'>',
      placeholder,
      ~s'</text>'
    ]
  end

  @spec dots(Datapoint.points(), SparklineSvg.opts()) :: iolist()
  defp dots(_datapoints, %{dots: nil}), do: ""

  defp dots(datapoints, options) do
    %{dots: %{color: color, radius: radius, class: class}} = options

    attrs =
      if class == nil,
        do: [~s'fill="', color, ~s'"'],
        else: [~s'class="', class, ~s'"']

    Enum.map(datapoints, fn %{x: x, y: y} ->
      x = float_to_string(x)
      y = float_to_string(y)

      [~s'<circle cx="', x, ~s'" cy="', y, ~s'" r="#{radius}" ', attrs, ~s' />']
    end)
  end

  @spec line(Datapoint.points(), SparklineSvg.opts()) :: iolist()
  defp line(_datapoints, %{line: nil}), do: ""

  defp line([datapoint], options) do
    %{line: %{color: color, width: width, class: class}} = options

    left = datapoint.x - options.width / 10
    right = datapoint.x + options.width / 10

    attrs =
      if class == nil,
        do: [~s'fill="none" stroke="', color, ~s'" stroke-width="', "#{width}", ~s'"'],
        else: [~s'class="', class, ~s'"']

    path = ["M#{left},", float_to_string(datapoint.y), "L#{right},", float_to_string(datapoint.y)]
    [~s'<path d="', path, ~s'" ', attrs, ~s' />']
  end

  defp line(datapoints, options) do
    %{line: %{color: color, width: width, class: class}} = options

    attrs =
      if class == nil,
        do: [~s'fill="none" stroke="', color, ~s'" stroke-width="', "#{width}", ~s'"'],
        else: [~s'class="', class, ~s'"']

    [~s'<path d="', compute_curve(datapoints, options), ~s'" ', attrs, ~s' />']
  end

  @spec area(Datapoint.points(), SparklineSvg.opts()) :: iolist()
  defp area(_datapoints, %{area: nil}), do: ""
  defp area([_points], _options), do: ""

  defp area(datapoints, options) do
    %{area: %{color: color, class: class}, height: height} = options

    # Extract the x value of the first datapoint to know where to finish the area.
    [%{x: x, y: _y} | _] = datapoints

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
      float_to_string(min(x1, x2)),
      ~s'" y="#{-width}" width="',
      float_to_string(abs(x2 - x1)),
      ~s'" height="#{height + 2 * width}" ',
      attrs,
      ~s' />'
    ]
  end

  defp marker(%Marker{position: _x} = marker, options) do
    %{
      position: x,
      options: %{stroke_color: color, stroke_width: width, class: class}
    } = marker

    %{height: height} = options

    attrs =
      if class == nil,
        do: [~s'fill="none" stroke="', color, ~s'" stroke-width="', "#{width}", ~s'"'],
        else: [~s'class="', class, ~s'"']

    [~s'<path d="M', tuple_to_string({x, 0.0}), ~s'V#{height}" ', attrs, ~s' />']
  end

  @spec compute_curve(Datapoint.points(), SparklineSvg.opts()) :: iolist()
  defp compute_curve([%{x: x, y: y} = curr | rest], options) do
    ["M#{tuple_to_string({x, y})}"]
    |> compute_curve(rest, curr, curr, options)
  end

  @spec compute_curve(
          iolist(),
          Datapoint.points(),
          Datapoint.point(),
          Datapoint.point(),
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
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          Datapoint.point(),
          SparklineSvg.opts()
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
          SparklineSvg.opts()
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

  @spec tuple_to_string({number(), number()}) :: iolist()
  defp tuple_to_string({x, y}) do
    [float_to_string(x), ",", float_to_string(y)]
  end

  @spec float_to_string(float()) :: String.t()
  defp float_to_string(float) when is_float(float) do
    float
    |> Float.round(3)
    |> Float.to_string()
  end
end
