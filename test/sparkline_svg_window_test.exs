defmodule SparklineSvgWindowTest do
  use ExUnit.Case, async: true

  test "todo1" do
    {:ok, sparkline} =
      [{0, 2}, {1, 2}, {2, 2}]
      |> SparklineSvg.new()
      |> SparklineSvg.set_x_window(min: 1)
      |> SparklineSvg.dry_run()

    assert sparkline.datapoints == [{2.0, 25.0}, {198.0, 25.0}]

    {:ok, sparkline} =
      [2, 2, 2]
      |> SparklineSvg.new()
      |> SparklineSvg.set_x_window(min: 1)
      |> SparklineSvg.dry_run()

    assert sparkline.datapoints == [{2.0, 25.0}, {198.0, 25.0}]
  end
end
