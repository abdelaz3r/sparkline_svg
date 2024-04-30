defmodule SparklineSvg.Core do
  @moduledoc """
  Internal module of `m:SparklineSvg` that contains the core logic of the library. It is only
  public for types documentation purposes and should not be used directly.
  """

  alias SparklineSvg.Marker
  alias SparklineSvg.ReferenceLine

  @typedoc false
  @typep min_max :: {number(), number()}

  @typedoc "Internal representation of a x value of a point"
  @type x :: number()

  @typedoc "Internal representation of a y value of a point"
  @type y :: number()

  @typedoc "Internal representation of a point"
  @type point :: {x(), y()}

  @typedoc "Internal representation of a list of points"
  @type points :: list(point())

  @doc false
  @spec compute(SparklineSvg.t()) :: SparklineSvg.t()
  def compute(%SparklineSvg{datapoints: []} = sparkline) do
    sparkline
  end

  def compute(%SparklineSvg{} = sparkline) do
    %{
      datapoints: datapoints,
      ref_lines: ref_lines,
      markers: markers,
      options: %{internal: internal_opts},
      window: window
    } = sparkline

    min_max_x = get_min_max_x(datapoints, window)
    min_max_y = get_min_max_y(datapoints)

    %SparklineSvg{
      sparkline
      | datapoints: resize_datapoints(datapoints, min_max_x, min_max_y, internal_opts),
        markers: resize_markers(markers, min_max_x, internal_opts),
        ref_lines: calc_resize_ref_lines(ref_lines, datapoints, min_max_y, internal_opts)
    }
  end

  @spec get_min_max_x(points(), SparklineSvg.window()) :: min_max()
  defp get_min_max_x(datapoints, window) do
    [{min_x, _} | _tail] = datapoints
    {max_x, _} = List.last(datapoints)

    {min_x, max_x} =
      cond do
        max_x - min_x != 0 -> {min_x, max_x}
        min_x == 0 -> {-1, 1}
        true -> {0, 2 * min_x}
      end

    min_x = if window.min == :auto, do: min_x, else: window.min
    max_x = if window.max == :auto, do: max_x, else: window.max

    {min_x, max_x}
  end

  @spec get_min_max_y(points()) :: min_max()
  defp get_min_max_y(datapoints) do
    [{_, y} | _tail] = datapoints
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(datapoints, fn {_, y} -> y end)

    cond do
      max_y - min_y != 0 -> {min_y, max_y}
      y == 0 -> {-1, 1}
      true -> {0, 2 * y}
    end
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
