defmodule SparklineSvgDrawTest do
  use ExUnit.Case, async: true

  test "to_svg/1 with empty chart" do
    assert SparklineSvg.new([]) |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'}
  end

  test "to_svg!/1 with empty chart" do
    assert SparklineSvg.new([]) |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with empty chart and show everything" do
    assert SparklineSvg.new([])
           |> SparklineSvg.show_dots()
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_area()
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with empty chart and placeholder" do
    assert SparklineSvg.new([], placeholder: "No data") |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><text x="50%" y="50%" text-anchor="middle">No data</text></svg>'
  end

  test "to_svg!/1 with one point (dots)" do
    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_dots() |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="100.0" cy="25.0" r="1" fill="black" /></svg>'
  end

  test "to_svg!/1 with one point (line)" do
    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_line() |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M80.0,25.0L120.0,25.0" fill="none" stroke="black" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with one point (area)" do
    assert SparklineSvg.new([{1, 0}]) |> SparklineSvg.show_area() |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with non-default options" do
    assert SparklineSvg.new([1, 2], width: 10, height: 10, padding: 1) |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with non-default options (for dots)" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_dots(radius: 2, color: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" r="2" fill="red" /><circle cx="198.0" cy="2.0" r="2" fill="red" /></svg>'
  end

  test "to_svg!/1 with non-default options (for line)" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_line(width: 1, color: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="red" stroke-width="1" /></svg>'

    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_line(width: 1, dasharray: "2 3")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="black" stroke-width="1" stroke-dasharray="2 3" /></svg>'
  end

  test "to_svg!/1 with non-default options (for area)" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_area(color: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" fill="red" stroke="none" /></svg>'
  end

  test "to_svg!/1 with non-default options (all)" do
    assert SparklineSvg.new([1, 2], width: 10, height: 10, padding: 1, smoothing: 0)
           |> SparklineSvg.show_dots(radius: 2, color: "red")
           |> SparklineSvg.show_line(width: 1, color: "red")
           |> SparklineSvg.show_area(color: "red")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg"><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0V10H1.0Z" fill="red" stroke="none" /><path d="M1.0,9.0C1.0,9.0 9.0,1.0 9.0,1.0" fill="none" stroke="red" stroke-width="1" /><circle cx="1.0" cy="9.0" r="2" fill="red" /><circle cx="9.0" cy="1.0" r="2" fill="red" /></svg>'
  end

  test "to_svg!/1 with class options" do
    assert SparklineSvg.new([1, 2], class: "sparkline")
           |> SparklineSvg.show_dots(class: "dot")
           |> SparklineSvg.show_line(class: "line")
           |> SparklineSvg.show_area(class: "area")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" class="sparkline" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0V50H2.0Z" class="area" /><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" class="line" /><circle cx="2.0" cy="48.0" r="1" class="dot" /><circle cx="198.0" cy="2.0" r="1" class="dot" /></svg>'
  end

  test "to_svg!/1 with marker" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_line(width: 1, color: "red")
           |> SparklineSvg.add_marker(0)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C31.4,41.1 168.6,8.9 198.0,2.0" fill="none" stroke="red" stroke-width="1" /><path d="M2.0,0.0V50" fill="none" stroke="red" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with markers and options" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker(0, stroke_width: 1, stroke_color: "blue")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" fill="none" stroke="blue" stroke-width="1" /></svg>'

    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker(0, stroke_dasharray: "3 2")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" fill="none" stroke="red" stroke-width="0.25" stroke-dasharray="3 2" /></svg>'
  end

  test "to_svg!/1 with area markers and options" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker([0.2, 0.8],
             stroke_width: 1,
             stroke_color: "blue",
             fill_color: "orange"
           )
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M158.8,0.0V50" fill="none" stroke="blue" stroke-width="1" /><path d="M41.2,0.0V50" fill="none" stroke="blue" stroke-width="1" /></svg>'
  end

  test "to_svg!/1 with markers and classe" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker(0, class: "sparkline-marker")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" class="sparkline-marker" /></svg>'
  end

  test "to_svg!/1 with max ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="2.0" x2="198" y2="2.0" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with min ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:min)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="48.0" x2="198" y2="48.0" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with avg ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:avg)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="30.75" x2="198" y2="30.75" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with median ref line" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:median)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="13.5" x2="198" y2="13.5" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end

  test "to_svg!/1 with ref line and options" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max, width: 1, color: "blue")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="2.0" x2="198" y2="2.0" fill="none" stroke="blue" stroke-width="1" /></svg>'

    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max, width: 1, dasharray: "3 2")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="2.0" x2="198" y2="2.0" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="1" stroke-dasharray="3 2" /></svg>'
  end

  test "to_svg!/1 with ref line and class options" do
    assert SparklineSvg.new([1, 2, 3, 1])
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max, class: "sparkline-max")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C11.8,44.55 47.733,31.9 67.333,25.0C86.933,18.1 113.067,-1.45 132.667,2.0C152.267,5.45 188.2,41.1 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="2.0" x2="198" y2="2.0" class="sparkline-max" /></svg>'
  end
end
