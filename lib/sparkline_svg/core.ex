defmodule SparklineSvg.Core do
  @moduledoc false

  alias SparklineSvg.Marker
  alias SparklineSvg.ReferenceLine

  @typedoc false
  @typep min_max :: {number(), number()}

  @typedoc false
  @type x :: number()

  @typedoc false
  @type y :: number()

  @typedoc false
  @type point :: {x(), y()}

  @typedoc false
  @type points :: list(point())

  @spec compute(SparklineSvg.t()) :: SparklineSvg.t()
  def compute(%SparklineSvg{datapoints: []} = sparkline) do
    sparkline
  end

  def compute(%SparklineSvg{} = sparkline) do
    %{datapoints: datapoints, ref_lines: ref_lines, markers: markers, options: options} =
      sparkline

    {min_max_x, min_max_y} = get_min_max(datapoints)

    %SparklineSvg{
      sparkline
      | datapoints: resize_datapoints(datapoints, min_max_x, min_max_y, options),
        markers: resize_markers(markers, min_max_x, options),
        ref_lines: calc_resize_ref_lines(ref_lines, datapoints, min_max_y, options)
    }
  end

  @spec get_min_max(points()) :: {min_max(), min_max()}
  defp get_min_max(datapoints) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(datapoints, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(datapoints, fn {_, y} -> y end)
    [{x, y} | _tail] = datapoints

    min_max_x =
      cond do
        max_x - min_x != 0 -> {min_x, max_x}
        x == 0 -> {-1, 1}
        true -> {0, 2 * x}
      end

    min_max_y =
      cond do
        max_y - min_y != 0 -> {min_y, max_y}
        y == 0 -> {-1, 1}
        true -> {0, 2 * y}
      end

    {min_max_x, min_max_y}
  end

  @spec resize_datapoints(points(), min_max(), min_max(), SparklineSvg.opts()) :: points()
  defp resize_datapoints(datapoints, min_max_x, min_max_y, options) do
    Enum.map(datapoints, fn {x, y} ->
      {resize_x(x, min_max_x, options), resize_y(y, min_max_y, options)}
    end)
  end

  @spec resize_markers(list(Marker.t()), min_max(), SparklineSvg.opts()) :: list(Marker.t())
  defp resize_markers(markers, min_max_x, options) do
    Enum.map(markers, fn marker ->
      case marker.position do
        {x1, x2} ->
          x1 = resize_x(x1, min_max_x, options)
          x2 = resize_x(x2, min_max_x, options)

          %Marker{marker | position: {x1, x2}}

        x ->
          %Marker{marker | position: resize_x(x, min_max_x, options)}
      end
    end)
  end

  @spec calc_resize_ref_lines(SparklineSvg.ref_lines(), points(), min_max(), SparklineSvg.opts()) ::
          SparklineSvg.ref_lines()
  defp calc_resize_ref_lines(ref_lines, datapoints, min_max_y, options) do
    ref_lines
    |> Enum.map(fn {type, ref_line} ->
      value =
        cond do
          is_atom(type) -> apply(ReferenceLine, type, [datapoints])
          is_function(type, 1) -> type.(datapoints)
        end

      position = resize_y(value, min_max_y, options)

      {type, %ReferenceLine{ref_line | position: position, value: value}}
    end)
    |> Map.new()
  end

  @spec resize_x(number(), min_max(), SparklineSvg.opts()) :: number()
  defp resize_x(x, {min_x, max_x}, %{width: width, padding: padding}) do
    inner_width = width - padding.left - padding.right
    (x - min_x) / (max_x - min_x) * inner_width + padding.left
  end

  @spec resize_y(number(), min_max(), SparklineSvg.opts()) :: number()
  defp resize_y(y, {min_y, max_y}, %{height: height, padding: padding}) do
    inner_height = height - padding.top - padding.bottom
    height - (y - min_y) / (max_y - min_y) * inner_height - padding.bottom
  end
end
