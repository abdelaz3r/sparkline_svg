defmodule SparklineSvgTest do
  use ExUnit.Case, async: true
  doctest SparklineSvg

  test "to_svg/2 with invalid dimension" do
    data = [{1, 1}, {2, 2}]

    assert SparklineSvg.new(data, width: 5, padding: 4) |> SparklineSvg.to_svg() ==
             {:error, :invalid_dimension}

    assert SparklineSvg.new(data, height: 5, padding: 4) |> SparklineSvg.to_svg() ==
             {:error, :invalid_dimension}
  end

  test "to_svg/2 with invalid datapoints type" do
    assert SparklineSvg.new([{"a", 1}, {"b", 2}]) |> SparklineSvg.to_svg() ==
             {:error, :invalid_x_type}
  end

  test "to_svg/2 with mixed datapoints type" do
    assert SparklineSvg.new([{1, 1}, {DateTime.utc_now(), 2}]) |> SparklineSvg.to_svg() ==
             {:error, :mixed_datapoints_types}

    assert SparklineSvg.new([{Time.utc_now(), 1}, {2, 2}]) |> SparklineSvg.to_svg() ==
             {:error, :mixed_datapoints_types}

    assert SparklineSvg.new([1, {2, 2}]) |> SparklineSvg.to_svg() ==
             {:error, :mixed_datapoints_types}

    assert SparklineSvg.new([{2, 2}, 1]) |> SparklineSvg.to_svg() ==
             {:error, :mixed_datapoints_types}
  end

  test "to_svg/2 with invalid datapoints type (y value)" do
    assert SparklineSvg.new([{1, "a"}, {2, "b"}]) |> SparklineSvg.to_svg() ==
             {:error, :invalid_y_type}
  end

  test "to_svg!/2 error handling" do
    assert_raise SparklineSvg.Error, "invalid_x_type", fn ->
      SparklineSvg.new([{"a", 1}, {"b", 2}]) |> SparklineSvg.to_svg!()
    end
  end

  test "to_svg/2 with empty chart" do
    assert SparklineSvg.new([])
           |> SparklineSvg.show_dots()
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_area()
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'}
  end

  test "to_svg/2 with empty chart and placeholder" do
    assert SparklineSvg.new([], placeholder: "No data") |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><text x="50%" y="50%" text-anchor="middle">No data</text></svg>'}
  end

  test "to_svg/2 with one point chart" do
    one_point_chart_dots =
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="100.0" cy="25.0" r="1" fill="black" /></svg>'

    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_dots() |> SparklineSvg.to_svg() ==
             {:ok, one_point_chart_dots}

    assert SparklineSvg.new([{1, 0}, {1, 2}]) |> SparklineSvg.show_dots() |> SparklineSvg.to_svg() ==
             {:ok, one_point_chart_dots}

    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_line() |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M80.0,25.0L120.0,25.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'}
  end

  test "to_svg/2 with only zeros as values" do
    assert SparklineSvg.new([{1, 0}, {2, 0}]) |> SparklineSvg.show_line() |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,25.0C31.4,25.0 168.6,25.0 198.0,25.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'}
  end

  test "to_svg/2 with various type of datapoints" do
    chart =
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() ==
             {:ok, chart}

    assert SparklineSvg.new([{1, 1}, {2, 2}])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() ==
             {:ok, chart}

    assert SparklineSvg.new([{-1, 1}, {0, 2}])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() ==
             {:ok, chart}

    assert SparklineSvg.new([{1.1, 1}, {1.2, 2}])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() ==
             {:ok, chart}

    assert SparklineSvg.new([
             {1_704_877_202, 1},
             {1_704_877_203, 2}
           ])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() == {:ok, chart}

    assert SparklineSvg.new([
             {Time.utc_now(), 1},
             {Time.utc_now() |> Time.add(1, :second), 2}
           ])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() == {:ok, chart}

    assert SparklineSvg.new([
             {Date.utc_today(), 1},
             {Date.utc_today() |> Date.add(1), 2}
           ])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() == {:ok, chart}

    assert SparklineSvg.new([
             {DateTime.utc_now(), 1},
             {DateTime.utc_now() |> DateTime.add(1, :second), 2}
           ])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() == {:ok, chart}

    assert SparklineSvg.new([
             {NaiveDateTime.utc_now(), 1},
             {NaiveDateTime.utc_now() |> NaiveDateTime.add(1, :second), 2}
           ])
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg() == {:ok, chart}
  end

  test "to_svg/2 with non-default options" do
    assert SparklineSvg.new([{1, 1}, {2, 2}], width: 10, height: 10, padding: 1)
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg"></svg>'}
  end

  test "to_svg/2 with non-default options (for dots)" do
    assert SparklineSvg.new([{1, 1}, {2, 2}])
           |> SparklineSvg.show_dots(radius: 2, color: "red")
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" r="2" fill="red" /><circle cx="198.0" cy="2.0" r="2" fill="red" /></svg>'}
  end

  test "to_svg/2 with non-default options (for line)" do
    assert SparklineSvg.new([{1, 1}, {2, 2}])
           |> SparklineSvg.show_line(width: 1, color: "red")
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="red" stroke-width="1" /></svg>'}
  end

  test "to_svg/2 with non-default options (for area)" do
    assert SparklineSvg.new([{1, 1}, {2, 2}])
           |> SparklineSvg.show_area(color: "red")
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" fill="red" stroke="none" /></svg>'}
  end

  test "to_svg/2 with non-default options (all)" do
    assert SparklineSvg.new([{1, 1}, {2, 2}], width: 10, height: 10, padding: 1, smoothing: 0)
           |> SparklineSvg.show_dots(radius: 2, color: "red")
           |> SparklineSvg.show_line(width: 1, color: "red")
           |> SparklineSvg.show_area(color: "red")
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg"><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0V10H1.0Z" fill="red" stroke="none" /><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0" fill="none" stroke="red" stroke-width="1" /><circle cx="1.0" cy="9.0" r="2" fill="red" /><circle cx="9.0" cy="1.0" r="2" fill="red" /></svg>'}
  end

  test "to_svg/2 with class options" do
    assert SparklineSvg.new([{1, 1}, {2, 2}], class: "sparkline")
           |> SparklineSvg.show_dots(class: "dot")
           |> SparklineSvg.show_line(class: "line")
           |> SparklineSvg.show_area(class: "area")
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" class="sparkline" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" class="area" /><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" class="line" /><circle cx="2.0" cy="48.0" r="1" class="dot" /><circle cx="198.0" cy="2.0" r="1" class="dot" /></svg>'}
  end

  test "as_data_uri/1" do
    assert [{1, 1}, {2, 2}]
           |> SparklineSvg.new()
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg!()
           |> SparklineSvg.as_data_uri() ==
             "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiB2aWV3Qm94PSIwIDAgMjAwIDUwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxwYXRoIGQ9Ik0yLjAsNDguMEMzMS40LDQxLjEgMTY4LjYsOC45IDE5OC4wLDIuMCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIwLjI1IiAvPjwvc3ZnPg=="
  end
end
