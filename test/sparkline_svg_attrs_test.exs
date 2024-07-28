defmodule SparklineSvgAttrsTest do
  use ExUnit.Case, async: true

  test "to_svg!/1 with custom attrs" do
    assert SparklineSvg.new([1, 2], a: "a", b: 2, "test-c": "c")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg a="a" b="2" height="100%" test-c="c" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with custom attrs (check precision)" do
    assert SparklineSvg.new([1, 2], a: 1.12345)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg a="1.123" height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'

    assert SparklineSvg.new([1, 2], a: 1.19999, precision: 1)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg a="1.2" height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"></svg>'
  end

  test "to_svg!/1 with show dots function attribute" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_dots("data-value": fn {_x, y} -> "Value: #{y}" end)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" data-value="Value: 1" fill="black" r="1" /><circle cx="198.0" cy="2.0" data-value="Value: 2" fill="black" r="1" /></svg>'

    assert SparklineSvg.new([{~D[2021-01-01], 1}, {~D[2021-01-02], 2}])
           |> SparklineSvg.show_dots("data-label": fn {x, _y} -> "Label: #{x}" end)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><circle cx="2.0" cy="48.0" data-label="Label: 2021-01-01" fill="black" r="1" /><circle cx="198.0" cy="2.0" data-label="Label: 2021-01-02" fill="black" r="1" /></svg>'
  end

  test "to_svg!/1 with show ref line function attribute" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.show_ref_line(:max,
             "data-label": "Max ref line",
             "data-value": fn y -> "Value: #{y}" end
           )
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><line data-label="Max ref line" data-value="Value: 2" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" x1="2" x2="198" y1="2.0" y2="2.0" /></svg>'

    assert SparklineSvg.new([1.2345, 3.654342])
           |> SparklineSvg.show_ref_line(:avg, "data-value": fn y -> "Value: #{y}" end)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg height="100%" viewBox="0 0 200 50" width="100%" xmlns="http://www.w3.org/2000/svg"><line data-value="Value: 2.444" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" x1="2" x2="198" y1="25.0" y2="25.0" /></svg>'
  end
end
