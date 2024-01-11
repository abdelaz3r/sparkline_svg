defmodule SimpleChartsLineTest do
  use ExUnit.Case, async: true

  alias SimpleCharts.Line

  setup do
    line_chart =
      "<svg width=\"auto\" height=\"auto\" viewBox=\"0 0 200 100\" xmlns=\"http://www.w3.org/2000/svg\">  <path d=\"M 6.0,94.0 C 43.6,76.4 156.4,23.6 194.0,6.0\" fill=\"none\" stroke=\"white\" stroke-width=\"0.25\" />  <circle cx=\"6.0\" cy=\"94.0\" r=\"1\" fill=\"white\" /><circle cx=\"194.0\" cy=\"6.0\" r=\"1\" fill=\"white\" /></svg>"

    line_chart_config =
      "<svg width=\"auto\" height=\"auto\" viewBox=\"0 0 300 50\" xmlns=\"http://www.w3.org/2000/svg\"> <path d=\"M 6.0,44.0 C 63.6,36.4 236.4,13.6 294.0,6.0 V 50 H 6.0 Z\" fill=\"black\" stroke=\"none\" />  <path d=\"M 6.0,44.0 C 63.6,36.4 236.4,13.6 294.0,6.0\" fill=\"none\" stroke=\"white\" stroke-width=\"0.25\" />  </svg>"

    %{line_chart: line_chart, line_chart_config: line_chart_config}
  end

  test "to_svg/2 error handling", _context do
    data = [{1, 1}, {2, 2}]

    assert Line.to_svg([]) == {:error, :empty_datapoints}
    assert Line.to_svg(data, width: 5, padding: 4) == {:error, :invalid_dimension}
    assert Line.to_svg(data, height: 5, padding: 4) == {:error, :invalid_dimension}
    assert Line.to_svg([{"a", 1}, {"b", 2}]) == {:error, :invalid_datapoints}
    assert Line.to_svg([{1, 1}, {1, 1}]) == {:error, :invalid_datapoints}
  end

  test "to_svg!/2 error handling", _context do
    data = [{1, 1}, {2, 2}]

    assert_raise Line, "empty_datapoints", fn -> Line.to_svg!([]) end
    assert_raise Line, "invalid_dimension", fn -> Line.to_svg!(data, width: 5, padding: 4) end
    assert_raise Line, "invalid_dimension", fn -> Line.to_svg!(data, height: 5, padding: 4) end
    assert_raise Line, "invalid_datapoints", fn -> Line.to_svg!([{"a", 1}, {"b", 2}]) end
    assert_raise Line, "invalid_datapoints", fn -> Line.to_svg!([{1, 1}, {1, 1}]) end
  end

  test "number datapoints", context do
    assert Line.to_svg([{1, 1}, {2, 2}]) == {:ok, context.line_chart}
    assert Line.to_svg([{-1, 1}, {0, 2}]) == {:ok, context.line_chart}
    assert Line.to_svg([{1.1, 1}, {1.2, 2}]) == {:ok, context.line_chart}
  end

  test "timestamp-based datapoints", context do
    data = [
      {1_704_877_202, 1},
      {1_704_877_203, 2}
    ]

    assert Line.to_svg(data) == {:ok, context.line_chart}
  end

  test "time-based datapoints", context do
    data = [
      {Time.utc_now(), 1},
      {Time.utc_now() |> Time.add(1, :second), 2}
    ]

    assert Line.to_svg(data) == {:ok, context.line_chart}
  end

  test "datetime-based datapoints", context do
    data = [
      {DateTime.utc_now(), 1},
      {DateTime.utc_now() |> DateTime.add(1, :second), 2}
    ]

    assert Line.to_svg(data) == {:ok, context.line_chart}
  end

  test "non-default options", context do
    assert Line.to_svg([{1, 1}, {2, 2}], width: 300, height: 50, dots?: false, area?: true) ==
             {:ok, context.line_chart_config}
  end
end
