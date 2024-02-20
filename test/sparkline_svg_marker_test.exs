defmodule SparklineSvgMarkerTest do
  use ExUnit.Case, async: true

  test "invalid x type marker" do
    assert SparklineSvg.new([1, 2]) |> SparklineSvg.add_marker("b") |> SparklineSvg.dry_run() ==
             {:error, :invalid_x_type}

    assert SparklineSvg.new([1, 2]) |> SparklineSvg.add_marker({"b", 1}) |> SparklineSvg.dry_run() ==
             {:error, :invalid_x_type}
  end

  test "mixed marker" do
    assert SparklineSvg.new([1, 2])
           |> SparklineSvg.add_marker(DateTime.utc_now())
           |> SparklineSvg.dry_run() ==
             {:error, :mixed_datapoints_types}

    assert SparklineSvg.new([{Time.utc_now(), 1}, {Time.utc_now() |> Time.add(1, :second), 2}])
           |> SparklineSvg.add_marker(1)
           |> SparklineSvg.dry_run() ==
             {:error, :mixed_datapoints_types}
  end

  test "valid marker" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2]) |> SparklineSvg.add_marker(0) |> SparklineSvg.dry_run()

    [marker | _] = sparkline.markers
    assert marker.position == 2.0

    {:ok, sparkline} =
      SparklineSvg.new([1, 2]) |> SparklineSvg.add_marker(1) |> SparklineSvg.dry_run()

    [marker | _] = sparkline.markers
    assert marker.position == 198.0
  end

  test "valid area marker" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2]) |> SparklineSvg.add_marker({0, 1}) |> SparklineSvg.dry_run()

    [marker | _] = sparkline.markers
    assert marker.position == {2.0, 198.0}
  end

  test "valid reversed area marker" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2]) |> SparklineSvg.add_marker({1, 0}) |> SparklineSvg.dry_run()

    [marker | _] = sparkline.markers
    assert marker.position == {198.0, 2.0}
  end

  test "empty markers" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2]) |> SparklineSvg.add_marker([]) |> SparklineSvg.dry_run()

    assert sparkline.markers == []
  end

  test "multiple markers" do
    {:ok, sparkline} =
      SparklineSvg.new([1, 2])
      |> SparklineSvg.add_marker(0)
      |> SparklineSvg.add_marker(1)
      |> SparklineSvg.add_marker({0, 1})
      |> SparklineSvg.dry_run()

    assert length(sparkline.markers) == 3
  end
end
