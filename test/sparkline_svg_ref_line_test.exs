defmodule SparklineSvgMRefLineTest do
  use ExUnit.Case, async: true

  alias SparklineSvg.ReferenceLine

  test "invalid ref line" do
    assert SparklineSvg.new([1, 2]) |> SparklineSvg.show_ref_line(:foo) |> SparklineSvg.dry_run() ==
             {:error, :invalid_ref_line_type}
  end

  test "valid :max ref line" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2, 3, 1]) |> SparklineSvg.show_ref_line(:max) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.max.value == 3
  end

  test ":max ref line with empty chart" do
    {:ok, sparkline} =
      SparklineSvg.new([]) |> SparklineSvg.show_ref_line(:max) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.max.value == nil
  end

  test "valid :min ref line" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2, 3, 1]) |> SparklineSvg.show_ref_line(:min) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.min.value == 1
  end

  test ":min ref line with empty chart" do
    {:ok, sparkline} =
      SparklineSvg.new([]) |> SparklineSvg.show_ref_line(:min) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.min.value == nil
  end

  test "valid :avg ref line" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2, 3, 1]) |> SparklineSvg.show_ref_line(:avg) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.avg.value == 1.75
  end

  test ":avg ref line with empty chart" do
    {:ok, sparkline} =
      SparklineSvg.new([]) |> SparklineSvg.show_ref_line(:avg) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.avg.value == nil
  end

  test "valid :median ref line" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2, 4])
      |> SparklineSvg.show_ref_line(:median)
      |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.median.value == 2

    {:ok, sparkline} =
      SparklineSvg.new([1, 2, 3, 1])
      |> SparklineSvg.show_ref_line(:median)
      |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.median.value == 1.5
  end

  test ":median ref line with empty chart" do
    {:ok, sparkline} =
      SparklineSvg.new([]) |> SparklineSvg.show_ref_line(:median) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.median.value == nil
  end

  test "valid multiple ref lines" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2, 3, 1])
      |> SparklineSvg.show_ref_line(:max)
      |> SparklineSvg.show_ref_line(:min)
      |> SparklineSvg.show_ref_line(:avg)
      |> SparklineSvg.show_ref_line(:median)
      |> SparklineSvg.dry_run()

    assert sparkline.ref_lines.max.value == 3
    assert sparkline.ref_lines.min.value == 1
    assert sparkline.ref_lines.avg.value == 1.75
    assert sparkline.ref_lines.median.value == 1.5
  end

  test "valid custom ref lines" do
    fixed = fn _ -> 0.33 end
    percentile_99 = ReferenceLine.percentile(99)

    {:ok, sparkline} =
      SparklineSvg.new(1..200)
      |> SparklineSvg.show_ref_line(percentile_99)
      |> SparklineSvg.show_ref_line(fixed)
      |> SparklineSvg.dry_run()

    assert sparkline.ref_lines[percentile_99].value == 198.99
    assert sparkline.ref_lines[fixed].value == 0.33
  end

  test "custom ref line with empty chart" do
    fun = fn _ -> 7 end

    {:ok, sparkline} =
      SparklineSvg.new([]) |> SparklineSvg.show_ref_line(fun) |> SparklineSvg.dry_run()

    assert sparkline.ref_lines[fun].value == nil
  end
end
