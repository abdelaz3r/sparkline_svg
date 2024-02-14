defmodule SparklineSvgMRefLineTest do
  use ExUnit.Case, async: true

  test "to_svg/2 with invalid ref line" do
    assert SparklineSvg.new([{1, 1}, {2, 2}])
           |> SparklineSvg.show_ref_line(:unknown)
           |> SparklineSvg.to_svg() ==
             {:error, :invalid_ref_line_type}
  end

  test "to_svg/2 with valid max ref line" do
    assert SparklineSvg.new([1, 2, 1], smoothing: 0)
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C2.0,48.0 100.0,2.0 100.0,2.0C100.0,2.0 198.0,48.0 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="2.0" x2="198" y2="2.0" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end

  test "to_svg/2 with valid min ref line" do
    assert SparklineSvg.new([1, 2, 1], smoothing: 0)
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:min)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C2.0,48.0 100.0,2.0 100.0,2.0C100.0,2.0 198.0,48.0 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="48.0" x2="198" y2="48.0" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end

  test "to_svg/2 with valid avg ref line" do
    assert SparklineSvg.new([1, 2, 1], smoothing: 0)
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:avg)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C2.0,48.0 100.0,2.0 100.0,2.0C100.0,2.0 198.0,48.0 198.0,48.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="32.667" x2="198" y2="32.667" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end

  test "to_svg/2 with valid median ref line" do
    assert SparklineSvg.new([1, 2, 3], smoothing: 0)
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:median)
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C2.0,48.0 100.0,25.0 100.0,25.0C100.0,25.0 198.0,2.0 198.0,2.0" fill="none" stroke="black" stroke-width="0.25" /><line x1="2" y1="25.0" x2="198" y2="25.0" fill="none" stroke="rgba(0, 0, 0, 0.5)" stroke-width="0.25" /></svg>'
  end
end
