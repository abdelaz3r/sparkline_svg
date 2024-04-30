defmodule SparklineSvg.Draw do
  @moduledoc false

  alias SparklineSvg.Core
  alias SparklineSvg.Marker
  alias SparklineSvg.ReferenceLine

  @non_nullified_otps %{
    "svg" => [:viewBox, :xmlns],
    "text" => [],
    "path" => [:d],
    "circle" => [:cx, :cy],
    "rect" => [:x, :y, :width, :height],
    "line" => [:x1, :x2, :y1, :y2]
  }

  @spec chart(SparklineSvg.t()) :: iolist()
  def chart(%SparklineSvg{datapoints: []} = sparkline) do
    %{options: %{internal: internal_opts, svg: attrs} = opts} = sparkline

    render_tag("svg", attrs, placeholder(opts), internal_opts)
  end

  def chart(%SparklineSvg{} = sparkline) do
    %{
      datapoints: datapoints,
      markers: markers,
      ref_lines: ref_lines,
      options: %{internal: internal_opts, svg: attrs} = opts
    } = sparkline

    content = [
      area(datapoints, opts),
      line(datapoints, opts),
      dots(datapoints, opts),
      markers(markers, opts),
      ref_lines(ref_lines, opts)
    ]

    render_tag("svg", attrs, content, internal_opts)
  end

  @spec placeholder(SparklineSvg.opts()) :: iolist()
  defp placeholder(%{placeholder: nil}), do: ""

  defp placeholder(options) do
    %{internal: internal_opts, placeholder: %{options: attrs, content: content}} = options

    render_tag("text", attrs, content, internal_opts)
  end

  @spec dots(Core.points(), SparklineSvg.opts()) :: iolist()
  defp dots(_datapoints, %{dots: nil}), do: ""

  defp dots(datapoints, options) do
    %{internal: internal_opts, dots: attrs} = options

    Enum.map(datapoints, fn {x, y} ->
      attrs = Map.merge(attrs, %{cx: x, cy: y})

      render_tag("circle", attrs, internal_opts)
    end)
  end

  @spec line(Core.points(), SparklineSvg.opts()) :: iolist()
  defp line(_datapoints, %{line: nil}), do: ""

  defp line([{x, y}], options) do
    %{internal: internal_opts, line: attrs} = options

    left = cast(x - internal_opts.width / 10, internal_opts)
    right = cast(x + internal_opts.width / 10, internal_opts)
    path = ["M", left, ",", cast(y, internal_opts), "L", right, ",", cast(y, internal_opts)]
    attrs = Map.put(attrs, :d, path)

    render_tag("path", attrs, internal_opts)
  end

  defp line(datapoints, options) do
    %{internal: internal_opts, line: attrs} = options

    attrs = Map.put(attrs, :d, compute_curve(datapoints, internal_opts))

    render_tag("path", attrs, internal_opts)
  end

  @spec area(Core.points(), SparklineSvg.opts()) :: iolist()
  defp area(_datapoints, %{area: nil}), do: ""
  defp area([_points], _options), do: ""

  defp area(datapoints, options) do
    %{internal: internal_opts, area: attrs} = options

    # Extract the x value of the first datapoint to know where to finish the area.
    [{x, _y} | _] = datapoints

    height = cast(internal_opts.height, internal_opts)
    x = cast(x, internal_opts)
    path = [compute_curve(datapoints, internal_opts), "V", height, "H", x, "Z"]
    attrs = Map.put(attrs, :d, path)

    render_tag("path", attrs, internal_opts)
  end

  @spec markers(list(Marker.t()), SparklineSvg.opts()) :: iolist()
  defp markers(markers, options) do
    Enum.map(markers, fn marker -> marker(marker, options) end)
  end

  @spec marker(Marker.t(), SparklineSvg.opts()) :: iolist()
  defp marker(%Marker{position: {_x1, _x2}} = marker, options) do
    %{position: {x1, x2}, options: attrs} = marker
    %{internal: %{height: height} = internal_opts} = options

    attrs = Map.merge(attrs, %{x: min(x1, x2), y: -1, width: abs(x2 - x1), height: height + 2})

    render_tag("rect", attrs, internal_opts)
  end

  defp marker(%Marker{position: _x} = marker, options) do
    %{position: x, options: attrs} = marker
    %{internal: %{height: height} = internal_opts} = options

    path = ["M", join_cast({x, 0.0}, internal_opts), "V", cast(height, internal_opts)]
    attrs = Map.put(attrs, :d, path)

    render_tag("path", attrs, internal_opts)
  end

  @spec ref_lines(SparklineSvg.ref_lines(), SparklineSvg.opts()) :: iolist()
  defp ref_lines(ref_lines, options) do
    Enum.map(ref_lines, fn {_type, ref_line} -> ref_line(ref_line, options) end)
  end

  @spec ref_line(ReferenceLine.t(), SparklineSvg.opts()) :: iolist()
  defp ref_line(ref_line, options) do
    %{position: y, options: attrs} = ref_line
    %{internal: %{padding: padding, width: width} = internal_opts} = options

    attrs = Map.merge(attrs, %{x1: padding.left, x2: width - padding.right, y1: y, y2: y})

    render_tag("line", attrs, internal_opts)
  end

  @spec compute_curve(Core.points(), SparklineSvg.opts()) :: iolist()
  defp compute_curve([curr | rest], opts) do
    ["M", join_cast(curr, opts)]
    |> compute_curve(rest, curr, curr, opts)
  end

  @spec compute_curve(
          iolist(),
          Core.points(),
          Core.point(),
          Core.point(),
          SparklineSvg.opts()
        ) :: iolist()
  defp compute_curve(acc, [curr | [next | _] = rest], prev2, prev1, opts) do
    acc
    |> curve_command(prev2, prev1, curr, next, opts)
    |> compute_curve(rest, prev1, curr, opts)
  end

  defp compute_curve(acc, [curr], prev2, prev1, opts) do
    curve_command(acc, prev2, prev1, curr, curr, opts)
  end

  @spec curve_command(
          iolist(),
          Core.point(),
          Core.point(),
          Core.point(),
          Core.point(),
          SparklineSvg.opts()
        ) :: iolist()
  defp curve_command(acc, prev2, prev1, curr, next, opts) do
    cp1 = calculate_control_point(prev1, prev2, curr, :left, opts)
    cp2 = calculate_control_point(curr, prev1, next, :right, opts)

    [acc, "C", join_cast(cp1, opts), " ", join_cast(cp2, opts), " ", join_cast(curr, opts)]
  end

  @spec calculate_control_point(
          Core.point(),
          Core.point(),
          Core.point(),
          :left | :right,
          SparklineSvg.opts()
        ) :: {number(), number()}
  defp calculate_control_point({x, y}, prev, next, direction, opts) do
    {length, angle} = calculate_line(prev, next)

    angle = if direction == :right, do: angle + :math.pi(), else: angle
    length = length * opts.smoothing

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

  @typep attr_value :: SparklineSvg.option_value() | iolist()
  @typep attrs :: %{atom() => attr_value()}

  @spec render_tag(String.t(), attrs(), SparklineSvg.opts()) :: iolist()
  defp render_tag(name, attributes, opts) do
    ["<", name, render_attributes(name, attributes, opts), " />"]
  end

  @spec render_tag(String.t(), attrs(), iolist(), SparklineSvg.opts()) :: iolist()
  defp render_tag(name, attributes, content, opts) when is_list(content) do
    ["<", name, render_attributes(name, attributes, opts), ">", content, "</", name, ">"]
  end

  defp render_tag(name, attributes, content, opts) do
    render_tag(name, attributes, [content], opts)
  end

  @spec render_attributes(String.t(), attrs(), SparklineSvg.opts()) :: iolist()
  defp render_attributes(tag_name, attributes, opts) do
    has_class = Map.has_key?(attributes, :class)
    attrs_to_keep = [:class | @non_nullified_otps[tag_name]]

    attributes
    |> Enum.filter(fn {name, _value} -> if has_class, do: name in attrs_to_keep, else: true end)
    |> Enum.map(fn {name, value} -> {Atom.to_string(name), cast(value, opts)} end)
    |> Enum.sort()
    |> Enum.map(fn {name, value} -> [" ", name, ~s'="', value, ~s'"'] end)
  end

  @spec join_cast(Core.point(), SparklineSvg.opts()) :: iolist()
  defp join_cast({x, y}, opts) do
    [cast(x, opts), ",", cast(y, opts)]
  end

  @spec cast(attr_value(), SparklineSvg.opts()) :: iolist()
  defp cast(value, _opts) when is_list(value), do: value
  defp cast(value, _opts) when is_binary(value), do: value
  defp cast(value, _opts) when is_integer(value), do: Integer.to_string(value)

  defp cast(value, opts) when is_float(value) do
    value
    |> Float.round(opts.precision)
    |> Float.to_string()
  end
end
