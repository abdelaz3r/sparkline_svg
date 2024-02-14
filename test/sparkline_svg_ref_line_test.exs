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

  test "to_svg/2 with valid ref line" do
    assert SparklineSvg.new([1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 10, 2], smoothing: 0)
           |> SparklineSvg.show_dots()
           |> SparklineSvg.show_line()
           |> SparklineSvg.show_ref_line(:max, color: "blue")
           |> SparklineSvg.show_ref_line(:min, color: "green")
           |> SparklineSvg.show_ref_line(:avg, color: "red")
           |> SparklineSvg.show_ref_line(:median, color: "yellow")
           |> SparklineSvg.to_svg!() ==
             ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,48.0C2.0,48.0 18.333,42.889 18.333,42.889C18.333,42.889 34.667,37.778 34.667,37.778C34.667,37.778 51.0,37.778 51.0,37.778C51.0,37.778 67.333,37.778 67.333,37.778C67.333,37.778 83.667,37.778 83.667,37.778C83.667,37.778 100.0,37.778 100.0,37.778C100.0,37.778 116.333,37.778 116.333,37.778C116.333,37.778 132.667,37.778 132.667,37.778C132.667,37.778 149.0,37.778 149.0,37.778C149.0,37.778 165.333,37.778 165.333,37.778C165.333,37.778 181.667,2.0 181.667,2.0C181.667,2.0 198.0,42.889 198.0,42.889" fill="none" stroke="black" stroke-width="0.25" /><circle cx="2.0" cy="48.0" r="1" fill="black" /><circle cx="18.333" cy="42.889" r="1" fill="black" /><circle cx="34.667" cy="37.778" r="1" fill="black" /><circle cx="51.0" cy="37.778" r="1" fill="black" /><circle cx="67.333" cy="37.778" r="1" fill="black" /><circle cx="83.667" cy="37.778" r="1" fill="black" /><circle cx="100.0" cy="37.778" r="1" fill="black" /><circle cx="116.333" cy="37.778" r="1" fill="black" /><circle cx="132.667" cy="37.778" r="1" fill="black" /><circle cx="149.0" cy="37.778" r="1" fill="black" /><circle cx="165.333" cy="37.778" r="1" fill="black" /><circle cx="181.667" cy="2.0" r="1" fill="black" /><circle cx="198.0" cy="42.889" r="1" fill="black" /><line x1="2" y1="2.0" x2="198" y2="2.0" fill="none" stroke="blue" stroke-width="0.25" /><line x1="2" y1="48.0" x2="198" y2="48.0" fill="none" stroke="green" stroke-width="0.25" /><line x1="2" y1="36.598" x2="198" y2="36.598" fill="none" stroke="red" stroke-width="0.25" /><line x1="2" y1="37.778" x2="198" y2="37.778" fill="none" stroke="yellow" stroke-width="0.25" /></svg>'
  end
end
