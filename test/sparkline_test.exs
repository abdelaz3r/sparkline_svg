defmodule SparklineTest do
  use ExUnit.Case, async: true

  setup do
    chart = """
    <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  <path\n  d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0"\n  fill="none"\n  stroke="black"\n  stroke-width="0.25" />\n\n  <circle\n  cx="6.0"\n  cy="94.0"\n  r="1"\n  fill="black" />\n<circle\n  cx="194.0"\n  cy="6.0"\n  r="1"\n  fill="black" />\n\n</svg>
    """

    empty_point_chart = """
    <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  <text x="50%" y="50%" text-anchor="middle">\n    No data\n  </text>\n</svg>
    """

    one_point_chart = """
    <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  <path\n    d="M6,50.0L188,50.0"\n    fill="none"\n    stroke="black"\n    stroke-width="0.25" />\n  <circle\n    cx="100.0"\n    cy="50.0"\n    r="1"\n    fill="black" />\n</svg>
    """

    only_zero_chart = """
    <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  <path\n  d="M6.0,50.0C43.6,50.0 156.4,50.0 194.0,50.0"\n  fill="none"\n  stroke="black"\n  stroke-width="0.25" />\n\n  <circle\n  cx="6.0"\n  cy="50.0"\n  r="1"\n  fill="black" />\n<circle\n  cx="194.0"\n  cy="50.0"\n  r="1"\n  fill="black" />\n\n</svg>
    """

    chart_config = """
    <svg width="100%" height="100%"\n  viewBox="0 0 300 50"\n  xmlns="http://www.w3.org/2000/svg">\n  <path\n  d="M6.0,44.0C63.6,36.4 236.4,13.6 294.0,6.0V50H6.0Z"\n  fill="rgba(0, 0, 0, 0.2)"\n  stroke="none" />\n\n  <path\n  d="M6.0,44.0C63.6,36.4 236.4,13.6 294.0,6.0"\n  fill="none"\n  stroke="black"\n  stroke-width="0.25" />\n\n  <circle\n  cx="6.0"\n  cy="44.0"\n  r="1"\n  fill="black" />\n<circle\n  cx="294.0"\n  cy="6.0"\n  r="1"\n  fill="black" />\n\n</svg>
    """

    data_uri =
      "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIgogIHZpZXdCb3g9IjAgMCAyMDAgMTAwIgogIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgCiAgPHBhdGgKICBkPSJNNi4wLDk0LjBDNDMuNiw3Ni40IDE1Ni40LDIzLjYgMTk0LjAsNi4wIgogIGZpbGw9Im5vbmUiCiAgc3Ryb2tlPSJibGFjayIKICBzdHJva2Utd2lkdGg9IjAuMjUiIC8+CgogIDxjaXJjbGUKICBjeD0iNi4wIgogIGN5PSI5NC4wIgogIHI9IjEiCiAgZmlsbD0iYmxhY2siIC8+CjxjaXJjbGUKICBjeD0iMTk0LjAiCiAgY3k9IjYuMCIKICByPSIxIgogIGZpbGw9ImJsYWNrIiAvPgoKPC9zdmc+Cg=="

    %{
      chart: chart,
      empty_point_chart: empty_point_chart,
      one_point_chart: one_point_chart,
      only_zero_chart: only_zero_chart,
      chart_config: chart_config,
      data_uri: data_uri
    }
  end

  test "to_svg/2 with invalid dimension", _context do
    data = [{1, 1}, {2, 2}]

    assert Sparkline.to_svg(data, width: 5, padding: 4) == {:error, :invalid_dimension}
    assert Sparkline.to_svg(data, height: 5, padding: 4) == {:error, :invalid_dimension}
  end

  test "to_svg/2 with invalid datapoints type", _context do
    assert Sparkline.to_svg([{"a", 1}, {"b", 2}]) == {:error, :invalid_x_type}
  end

  test "to_svg/2 with mixed datapoints type", _context do
    assert Sparkline.to_svg([{1, 1}, {DateTime.utc_now(), 2}]) ==
             {:error, :mixed_datapoints_types}

    assert Sparkline.to_svg([{Time.utc_now(), 1}, {2, 2}]) == {:error, :mixed_datapoints_types}
  end

  test "to_svg/2 with invalid datapoints type (y value)", _context do
    assert Sparkline.to_svg([{1, "a"}, {2, "b"}]) == {:error, :invalid_y_type}
  end

  test "to_svg!/2 error handling", _context do
    assert_raise Sparkline.Error, "invalid_x_type", fn ->
      Sparkline.to_svg!([{"a", 1}, {"b", 2}])
    end
  end

  test "to_svg/2 with valid egde-case", context do
    # empty chart
    assert Sparkline.to_svg([]) == {:ok, context.empty_point_chart}

    # one point chart
    assert Sparkline.to_svg([{1, 0}]) == {:ok, context.one_point_chart}
    assert Sparkline.to_svg([{1, 0}, {1, 2}]) == {:ok, context.one_point_chart}
  end

  test "to_svg/2 with number datapoints", context do
    assert Sparkline.to_svg([{1, 1}, {2, 2}]) == {:ok, context.chart}
    assert Sparkline.to_svg([{-1, 1}, {0, 2}]) == {:ok, context.chart}
    assert Sparkline.to_svg([{1.1, 1}, {1.2, 2}]) == {:ok, context.chart}
  end

  test "to_svg/2 with only zeros as values", context do
    assert Sparkline.to_svg([{1, 0}, {2, 0}]) == {:ok, context.only_zero_chart}
  end

  test "to_svg/2 with timestamp-based datapoints", context do
    data = [
      {1_704_877_202, 1},
      {1_704_877_203, 2}
    ]

    assert Sparkline.to_svg(data) == {:ok, context.chart}
  end

  test "to_svg/2 with time-based datapoints", context do
    data = [
      {Time.utc_now(), 1},
      {Time.utc_now() |> Time.add(1, :second), 2}
    ]

    assert Sparkline.to_svg(data) == {:ok, context.chart}
  end

  test "to_svg/2 with date-based datapoints", context do
    data = [
      {Date.utc_today(), 1},
      {Date.utc_today() |> Date.add(1), 2}
    ]

    assert Sparkline.to_svg(data) == {:ok, context.chart}
  end

  test "to_svg/2 with datetime-based datapoints", context do
    data = [
      {DateTime.utc_now(), 1},
      {DateTime.utc_now() |> DateTime.add(1, :second), 2}
    ]

    assert Sparkline.to_svg(data) == {:ok, context.chart}
  end

  test "to_svg/2 with non-default options", context do
    assert Sparkline.to_svg([{1, 1}, {2, 2}],
             width: 300,
             height: 50,
             show_dots: false,
             show_area: true
           ) ==
             {:ok, context.chart_config}
  end

  test "as_data_uri/1", context do
    data_uri =
      [{1, 1}, {2, 2}]
      |> Sparkline.to_svg!()
      |> Sparkline.as_data_uri()

    assert data_uri == context.data_uri
  end
end
