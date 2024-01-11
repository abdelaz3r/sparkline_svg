defmodule SimpleChartsLineTest do
  use ExUnit.Case, async: true

  setup do
    simple_line_chart =
      "<svg width=\"auto\" height=\"auto\" viewBox=\"0 0 200 100\" xmlns=\"http://www.w3.org/2000/svg\">\n  \n  <path\n  d=\"M 6.0,94.0  C 43.6,76.4 156.4,23.6 194.0,6.0\"\n  fill=\"none\"\n  stroke=\"white\"\n  stroke-width=\"0.25\" />\n\n  <circle\n  cx=\"6.0\"\n  cy=\"94.0\"\n  r=\"1\"\n  fill=\"white\" />\n<circle\n  cx=\"194.0\"\n  cy=\"6.0\"\n  r=\"1\"\n  fill=\"white\" />\n\n</svg>\n"

    %{simple_line_chart: simple_line_chart}
  end

  test "empty datapoints", _context do
    assert SimpleCharts.Line.to_svg([]) == {:error, :empty_datapoints}
  end

  test "number datapoints", context do
    assert SimpleCharts.Line.to_svg([{1, 1}, {2, 2}]) == {:ok, context.simple_line_chart}
    assert SimpleCharts.Line.to_svg([{-1, 1}, {0, 2}]) == {:ok, context.simple_line_chart}
  end

  test "timestamp-based datapoints", context do
    datapoints = [
      {1_704_877_202, 1},
      {1_704_877_203, 2}
    ]

    assert SimpleCharts.Line.to_svg(datapoints) == {:ok, context.simple_line_chart}
  end

  test "time-based datapoints", context do
    datapoints = [
      {Time.utc_now(), 1},
      {Time.utc_now() |> Time.add(1, :second), 2}
    ]

    assert SimpleCharts.Line.to_svg(datapoints) == {:ok, context.simple_line_chart}
  end

  test "datetime-based datapoints", context do
    datapoints = [
      {DateTime.utc_now(), 1},
      {DateTime.utc_now() |> DateTime.add(1, :second), 2}
    ]

    assert SimpleCharts.Line.to_svg(datapoints) == {:ok, context.simple_line_chart}
  end
end
