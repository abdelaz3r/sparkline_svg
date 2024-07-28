defmodule SparklineSvgDrawTest do
  use ExUnit.Case, async: true

  test "to_svg/1 with empty chart" do
    assert SparklineSvg.new([]) |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'}
  end

  test "to_svg!/1 with empty chart" do
    assert SparklineSvg.new([]) |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with empty chart and show everything" do
    assert SparklineSvg.new([])
           |> SparklineSvg.show_dots()
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_area()
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with empty chart and placeholder" do
    assert SparklineSvg.new([])
           |> SparklineSvg.set_placeholder("No data")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><text text-anchor="middle" x="50%" y="50%">No data</text></svg>'
  end

  test "to_svg!/1 with empty chart and placeholder with options" do
    assert SparklineSvg.new([])
           |> SparklineSvg.set_placeholder("No data", class: "placeholder")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><text class="placeholder">No data</text></svg>'
  end

  test "to_svg!/1 with one point (dots)" do
    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_dots() |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><circle cx="100.0" cy="25.0" fill="black" r="1" /></svg>'
  end

  test "to_svg!/1 with one point (line)" do
    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_line() |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M80.0,25.0L120.0,25.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with one point (area)" do
    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_area() |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with non-default options" do
    assert SparklineSvg.new([1, 2], w: 10, h: 10, padding: 1) |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 10 10" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with non-default options (for dots)" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_dots(r: 2, fill: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" fill="red" r="2" /><circle cx="198.0" cy="2.0" fill="red" r="2" /></svg>'
  end

  test "to_svg!/1 with non-default options (for line)" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_line("stroke-width": 1, stroke: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="red" stroke-width="1" /></svg>'

    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_line("stroke-width": 1, "stroke-dasharray": "2 3")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="black" stroke-dasharray="2 3" stroke-width="1" /></svg>'
  end

  test "to_svg!/1 with non-default options (for area)" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_area(fill: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" fill="red" stroke="none" /></svg>'
  end

  test "to_svg!/1 with non-default options (all)" do
    assert SparklineSvg.new([1, 2], w: 10, h: 10, padding: 1, smoothing: 0)
           |> SparklineSvg.show_dots(r: 2, fill: "red")
           |> SparklineSvg.show_line("stroke-width": 1, stroke: "red")
           |> SparklineSvg.show_area(fill: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 10 10" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0V10H1.0Z" fill="red" stroke="none" /><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0" fill="none" stroke="red" stroke-width="1" /><circle cx="1.0" cy="9.0" fill="red" r="2" /><circle cx="9.0" cy="1.0" fill="red" r="2" /></svg>'
  end

  test "to_svg!/1 with class options" do
    assert SparklineSvg.new([1, 2], class: "sparkline")
           |> SparklineSvg.show_dots(class: "dot")
           |> SparklineSvg.show_line(class: "line")
           |> SparklineSvg.show_area(class: "area")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg class="sparkline" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path class="area" d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" /><path class="line" d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" /><circle class="dot" cx="2.0" cy="48.0" /><circle class="dot" cx="198.0" cy="2.0" /></svg>'
  end

  test "to_svg!/1 with marker" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_line("stroke-width": 1, stroke: "red")
           |> SparklineSvg.add_marker(0)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="red" stroke-width="1" /><path d="M2.0,0.0V50" stroke="red" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with markers and options" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker(0, "stroke-width": 1, stroke: "blue")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" stroke="blue" stroke-width="1" /></svg>'

    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker(0, "stroke-dasharray": "3 2")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" stroke="red" stroke-dasharray="3 2" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with multiple area marker and options" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker([0.2, 0.8],
             "stroke-width": 1,
             stroke: "blue",
             fill: "orange"
           )
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M158.8,0.0V50" fill="orange" stroke="blue" stroke-width="1" /><path d="M41.2,0.0V50" fill="orange" stroke="blue" stroke-width="1" /></svg>'
  end

  test "to_svg!/1 with markers and class" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker(0, class: "sparkline-marker")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path class="sparkline-marker" d="M2.0,0.0V50" /></svg>'
  end

  test "to_svg!/1 with max ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" x1="2" x2="198" y1="2.0" y2="2.0" /></svg>'
  end

  test "to_svg!/1 with min ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:min)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" x1="2" x2="198" y1="48.0" y2="48.0" /></svg>'
  end

  test "to_svg!/1 with avg ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:avg)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" x1="2" x2="198" y1="30.75" y2="30.75" /></svg>'
  end

  test "to_svg!/1 with median ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:median)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" x1="2" x2="198" y1="36.5" y2="36.5" /></svg>'
  end

  test "to_svg!/1 with empty chart and median ref line" do
    assert SparklineSvg.new([])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:median)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with ref line and options" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max, "stroke-width": 1, stroke: "blue")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line fill="none" stroke="blue" stroke-width="1" x1="2" x2="198" y1="2.0" y2="2.0" /></svg>'

    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max, "stroke-width": 1, "stroke-dasharray": "3 2")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-dasharray="3 2" stroke-width="1" x1="2" x2="198" y1="2.0" y2="2.0" /></svg>'
  end

  test "to_svg!/1 with ref line and class options" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max, class: "sparkline-max")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line class="sparkline-max" x1="2" x2="198" y1="2.0" y2="2.0" /></svg>'
  end

  test "to_svg!/1 with different precision" do
    assert SparklineSvg.new([1, 2, 5, 2, 13], w: 13.2, h: 22.9, precision: 5)
           |> SparklineSvg.show_dots()
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_area()
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 13.2 22.9" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,20.9C2.345,20.66375 3.61,20.27 4.3,19.325C4.99,18.38 5.91,14.6 6.6,14.6C7.29,14.6 8.21,21.215 8.9,19.325C9.59,17.435 10.855,4.59875 11.2,2.0V22.9H2.0Z" fill="rgba(0, 0, 0, 0.1)" stroke="none" /><path d="M2.0,20.9C2.345,20.66375 3.61,20.27 4.3,19.325C4.99,18.38 5.91,14.6 6.6,14.6C7.29,14.6 8.21,21.215 8.9,19.325C9.59,17.435 10.855,4.59875 11.2,2.0" fill="none" stroke="black" stroke-width="0.25" /><circle cx="2.0" cy="20.9" fill="black" r="1" /><circle cx="4.3" cy="19.325" fill="black" r="1" /><circle cx="6.6" cy="14.6" fill="black" r="1" /><circle cx="8.9" cy="19.325" fill="black" r="1" /><circle cx="11.2" cy="2.0" fill="black" r="1" /></svg>'

    assert SparklineSvg.new([1, 2, 5, 2, 13], w: 13.2, h: 22.9, precision: 0)
           |> SparklineSvg.show_dots()
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_area()
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 13.2 22.9" width="100%" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,21.0C2.0,21.0 4.0,20.0 4.0,19.0C5.0,18.0 6.0,15.0 7.0,15.0C7.0,15.0 8.0,21.0 9.0,19.0C10.0,17.0 11.0,5.0 11.0,2.0V23.0H2.0Z" fill="rgba(0, 0, 0, 0.1)" stroke="none" /><path d="M2.0,21.0C2.0,21.0 4.0,20.0 4.0,19.0C5.0,18.0 6.0,15.0 7.0,15.0C7.0,15.0 8.0,21.0 9.0,19.0C10.0,17.0 11.0,5.0 11.0,2.0" fill="none" stroke="black" stroke-width="0.0" /><circle cx="2.0" cy="21.0" fill="black" r="1" /><circle cx="4.0" cy="19.0" fill="black" r="1" /><circle cx="7.0" cy="15.0" fill="black" r="1" /><circle cx="9.0" cy="19.0" fill="black" r="1" /><circle cx="11.0" cy="2.0" fill="black" r="1" /></svg>'
  end
end
