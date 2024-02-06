defmodule SparklineTest do
  use ExUnit.Case, async: true

  test "to_svg/2 with invalid dimension" do
    data = [{1, 1}, {2, 2}]

    assert Sparkline.new(data, width: 5, padding: 4) |> Sparkline.to_svg() ==
             {:error, :invalid_dimension}

    assert Sparkline.new(data, height: 5, padding: 4) |> Sparkline.to_svg() ==
             {:error, :invalid_dimension}
  end

  test "to_svg/2 with invalid datapoints type" do
    assert Sparkline.new([{"a", 1}, {"b", 2}]) |> Sparkline.to_svg() ==
             {:error, :invalid_x_type}
  end

  test "to_svg/2 with mixed datapoints type" do
    assert Sparkline.new([{1, 1}, {DateTime.utc_now(), 2}]) |> Sparkline.to_svg() ==
             {:error, :mixed_datapoints_types}

    assert Sparkline.new([{Time.utc_now(), 1}, {2, 2}]) |> Sparkline.to_svg() ==
             {:error, :mixed_datapoints_types}
  end

  test "to_svg/2 with invalid datapoints type (y value)" do
    assert Sparkline.new([{1, "a"}, {2, "b"}]) |> Sparkline.to_svg() == {:error, :invalid_y_type}
  end

  test "to_svg!/2 error handling" do
    assert_raise Sparkline.Error, "invalid_x_type", fn ->
      Sparkline.new([{"a", 1}, {"b", 2}]) |> Sparkline.to_svg!()
    end
  end

  test "to_svg/2 with empty chart" do
    assert Sparkline.new([])
           |> Sparkline.show_dots()
           |> Sparkline.show_line()
           |> Sparkline.show_area()
           |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n</svg>
              """}
  end

  test "to_svg/2 with empty chart and placeholder" do
    assert Sparkline.new([], placeholder: "No data") |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  <text x="50%" y="50%" text-anchor="middle">\n  No data\n</text>\n\n</svg>
              """}
  end

  test "to_svg/2 with one point chart" do
    one_point_chart_dots = """
    <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  \n  <circle\n  cx="100.0"\n  cy="50.0"\n  r="1"\n  fill="black" />\n\n</svg>
    """

    assert Sparkline.new([{1, 0}]) |> Sparkline.show_dots() |> Sparkline.to_svg() ==
             {:ok, one_point_chart_dots}

    assert Sparkline.new([{1, 0}, {1, 2}]) |> Sparkline.show_dots() |> Sparkline.to_svg() ==
             {:ok, one_point_chart_dots}

    assert Sparkline.new([{1, 0}]) |> Sparkline.show_line() |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  <path\n  d="M80.0,50.0L120.0,50.0"\n  fill="none"\n  stroke="black"\n  stroke-width="0.25" />\n\n  \n</svg>
              """}
  end

  test "to_svg/2 with only zeros as values" do
    assert Sparkline.new([{1, 0}, {2, 0}]) |> Sparkline.show_line() |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  <path\n  d="M6.0,50.0C43.6,50.0 156.4,50.0 194.0,50.0"\n  fill="none"\n  stroke="black"\n  stroke-width="0.25" />\n\n  \n</svg>
              """}
  end

  test "to_svg/2 with various type of datapoints" do
    chart = """
    <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  <path\n  d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0"\n  fill="none"\n  stroke="black"\n  stroke-width="0.25" />\n\n  \n</svg>
    """

    assert Sparkline.new([{1, 1}, {2, 2}])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() ==
             {:ok, chart}

    assert Sparkline.new([{-1, 1}, {0, 2}])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() ==
             {:ok, chart}

    assert Sparkline.new([{1.1, 1}, {1.2, 2}])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() ==
             {:ok, chart}

    assert Sparkline.new([
             {1_704_877_202, 1},
             {1_704_877_203, 2}
           ])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() == {:ok, chart}

    assert Sparkline.new([
             {Time.utc_now(), 1},
             {Time.utc_now() |> Time.add(1, :second), 2}
           ])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() == {:ok, chart}

    assert Sparkline.new([
             {Date.utc_today(), 1},
             {Date.utc_today() |> Date.add(1), 2}
           ])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() == {:ok, chart}

    assert Sparkline.new([
             {DateTime.utc_now(), 1},
             {DateTime.utc_now() |> DateTime.add(1, :second), 2}
           ])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() == {:ok, chart}
  end

  test "to_svg/2 with non-default options" do
    assert Sparkline.new([{1, 1}, {2, 2}], width: 10, height: 10, padding: 1)
           |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 10 10"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  \n  \n</svg>
              """}
  end

  test "to_svg/2 with non-default options (for dots)" do
    assert Sparkline.new([{1, 1}, {2, 2}])
           |> Sparkline.show_dots(radius: 2, color: "red")
           |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  \n  <circle\n  cx="6.0"\n  cy="94.0"\n  r="2"\n  fill="red" />\n<circle\n  cx="194.0"\n  cy="6.0"\n  r="2"\n  fill="red" />\n\n</svg>
              """}
  end

  test "to_svg/2 with non-default options (for line)" do
    assert Sparkline.new([{1, 1}, {2, 2}])
           |> Sparkline.show_line(width: 1, color: "red", smoothing: 0)
           |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  \n  <path\n  d="M6.0,94.0C6.0,94.0 194.0,6.0 194.0,6.0"\n  fill="none"\n  stroke="red"\n  stroke-width="1" />\n\n  \n</svg>
              """}
  end

  test "to_svg/2 with non-default options (for area)" do
    assert Sparkline.new([{1, 1}, {2, 2}])
           |> Sparkline.show_area(color: "red")
           |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 200 100"\n  xmlns="http://www.w3.org/2000/svg">\n  <path\n  d="M6.0,94.0C6.0,94.0 194.0,6.0 194.0,6.0V100H6.0Z"\n  fill="red"\n  stroke="none" />\n\n  \n  \n</svg>
              """}
  end

  test "to_svg/2 with non-default options (all)" do
    assert Sparkline.new([{1, 1}, {2, 2}], width: 10, height: 10, padding: 1)
           |> Sparkline.show_dots(radius: 2, color: "red")
           |> Sparkline.show_line(width: 1, color: "red", smoothing: 0)
           |> Sparkline.show_area(color: "red")
           |> Sparkline.to_svg() ==
             {:ok,
              """
              <svg width="100%" height="100%"\n  viewBox="0 0 10 10"\n  xmlns="http://www.w3.org/2000/svg">\n  <path\n  d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0V10H1.0Z"\n  fill="red"\n  stroke="none" />\n\n  <path\n  d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0"\n  fill="none"\n  stroke="red"\n  stroke-width="1" />\n\n  <circle\n  cx="1.0"\n  cy="9.0"\n  r="2"\n  fill="red" />\n<circle\n  cx="9.0"\n  cy="1.0"\n  r="2"\n  fill="red" />\n\n</svg>
              """}
  end

  test "as_data_uri/1" do
    assert [{1, 1}, {2, 2}]
           |> Sparkline.new()
           |> Sparkline.show_line()
           |> Sparkline.to_svg!()
           |> Sparkline.as_data_uri() ==
             "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIgogIHZpZXdCb3g9IjAgMCAyMDAgMTAwIgogIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgCiAgPHBhdGgKICBkPSJNNi4wLDk0LjBDNDMuNiw3Ni40IDE1Ni40LDIzLjYgMTk0LjAsNi4wIgogIGZpbGw9Im5vbmUiCiAgc3Ryb2tlPSJibGFjayIKICBzdHJva2Utd2lkdGg9IjAuMjUiIC8+CgogIAo8L3N2Zz4K"
  end
end
