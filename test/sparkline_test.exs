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
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"></svg>'}
  end

  test "to_svg/2 with empty chart and placeholder" do
    assert Sparkline.new([], placeholder: "No data") |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><text x="50%" y="50%" text-anchor="middle">No data</text></svg>'}
  end

  test "to_svg/2 with one point chart" do
    one_point_chart_dots =
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><circle cx="100.0" cy="50.0" r="1" fill="black" /></svg>'

    assert Sparkline.new([{1, 0}]) |> Sparkline.show_dots() |> Sparkline.to_svg() ==
             {:ok, one_point_chart_dots}

    assert Sparkline.new([{1, 0}, {1, 2}]) |> Sparkline.show_dots() |> Sparkline.to_svg() ==
             {:ok, one_point_chart_dots}

    assert Sparkline.new([{1, 0}]) |> Sparkline.show_line() |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M80.0,50.0L120.0,50.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'}
  end

  test "to_svg/2 with only zeros as values" do
    assert Sparkline.new([{1, 0}, {2, 0}]) |> Sparkline.show_line() |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,50.0C43.6,50.0 156.4,50.0 194.0,50.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'}
  end

  test "to_svg/2 with various type of datapoints" do
    chart =
      ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'

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

    assert Sparkline.new([
             {NaiveDateTime.utc_now(), 1},
             {NaiveDateTime.utc_now() |> NaiveDateTime.add(1, :second), 2}
           ])
           |> Sparkline.show_line()
           |> Sparkline.to_svg() == {:ok, chart}
  end

  test "to_svg/2 with non-default options" do
    assert Sparkline.new([{1, 1}, {2, 2}], width: 10, height: 10, padding: 1)
           |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg"></svg>'}
  end

  test "to_svg/2 with non-default options (for dots)" do
    assert Sparkline.new([{1, 1}, {2, 2}])
           |> Sparkline.show_dots(radius: 2, color: "red")
           |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><circle cx="6.0" cy="94.0" r="2" fill="red" /><circle cx="194.0" cy="6.0" r="2" fill="red" /></svg>'}
  end

  test "to_svg/2 with non-default options (for line)" do
    assert Sparkline.new([{1, 1}, {2, 2}])
           |> Sparkline.show_line(width: 1, color: "red")
           |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0" fill="none" stroke="red" stroke-width="1" /></svg>'}
  end

  test "to_svg/2 with non-default options (for area)" do
    assert Sparkline.new([{1, 1}, {2, 2}])
           |> Sparkline.show_area(color: "red")
           |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0V100H6.0Z" fill="red" stroke="none" /></svg>'}
  end

  test "to_svg/2 with non-default options (all)" do
    assert Sparkline.new([{1, 1}, {2, 2}], width: 10, height: 10, padding: 1, smoothing: 0)
           |> Sparkline.show_dots(radius: 2, color: "red")
           |> Sparkline.show_line(width: 1, color: "red")
           |> Sparkline.show_area(color: "red")
           |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg"><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0V10H1.0Z" fill="red" stroke="none" /><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0" fill="none" stroke="red" stroke-width="1" /><circle cx="1.0" cy="9.0" r="2" fill="red" /><circle cx="9.0" cy="1.0" r="2" fill="red" /></svg>'}
  end

  test "to_svg/2 with class options" do
    assert Sparkline.new([{1, 1}, {2, 2}], class: "sparkline")
           |> Sparkline.show_dots(class: "dot")
           |> Sparkline.show_line(class: "line")
           |> Sparkline.show_area(class: "area")
           |> Sparkline.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 100" class="sparkline" xmlns="http://www.w3.org/2000/svg"><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0V100H6.0Z" class="area" /><path d="M6.0,94.0C43.6,76.4 156.4,23.6 194.0,6.0" class="line" /><circle cx="6.0" cy="94.0" r="1" class="dot" /><circle cx="194.0" cy="6.0" r="1" class="dot" /></svg>'}
  end

  test "as_data_uri/1" do
    assert [{1, 1}, {2, 2}]
           |> Sparkline.new()
           |> Sparkline.show_line()
           |> Sparkline.to_svg!()
           |> Sparkline.as_data_uri() ==
             "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiB2aWV3Qm94PSIwIDAgMjAwIDEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNNi4wLDk0LjBDNDMuNiw3Ni40IDE1Ni40LDIzLjYgMTk0LjAsNi4wIiBmaWxsPSJub25lIiBzdHJva2U9ImJsYWNrIiBzdHJva2Utd2lkdGg9IjAuMjUiIC8+PC9zdmc+"
  end
end
