defmodule SparklineSvgTest do
  use ExUnit.Case, async: true
  doctest SparklineSvg

  test "invalid dimension" do
    data = [{1, 1}, {2, 2}]
    sparkline = SparklineSvg.new(data, w: 5, padding: 4)
    assert SparklineSvg.dry_run(sparkline) == {:error, :invalid_dimension}

    sparkline = SparklineSvg.new(data, h: 5, padding: 4)
    assert SparklineSvg.dry_run(sparkline) == {:error, :invalid_dimension}
  end

  test "invalid datapoints x type" do
    sparkline = SparklineSvg.new([{"a", 1}, {"b", 2}])
    assert SparklineSvg.dry_run(sparkline) == {:error, :invalid_x_type}
  end

  test "mixed datapoints type" do
    sparkline = SparklineSvg.new([{1, 1}, {DateTime.utc_now(), 2}])
    assert SparklineSvg.dry_run(sparkline) == {:error, :mixed_datapoints_types}

    sparkline = SparklineSvg.new([{Time.utc_now(), 1}, {2, 2}])
    assert SparklineSvg.dry_run(sparkline) == {:error, :mixed_datapoints_types}

    sparkline = SparklineSvg.new([1, {2, 2}])
    assert SparklineSvg.dry_run(sparkline) == {:error, :mixed_datapoints_types}

    sparkline = SparklineSvg.new([{2, 2}, 1])
    assert SparklineSvg.dry_run(sparkline) == {:error, :mixed_datapoints_types}
  end

  test "invalid datapoints y type" do
    sparkline = SparklineSvg.new([{1, "a"}, {2, "b"}])
    assert SparklineSvg.dry_run(sparkline) == {:error, :invalid_y_type}
  end

  test "valid padding" do
    data = [{1, 1}, {2, 2}]

    opts = [w: 10, h: 10, padding: 2]
    {:ok, sparkline} = SparklineSvg.new(data, opts) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 8.0}, {8.0, 2.0}]

    opts = [w: 10, h: 10, padding: [top: 5]]
    {:ok, sparkline} = SparklineSvg.new(data, opts) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 8.0}, {8.0, 5.0}]

    # different vertical and horizontal padding
    opts = [w: 10, h: 10, padding: [top: 2, bottom: 2, left: 3, right: 3]]
    {:ok, sparkline} = SparklineSvg.new(data, opts) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{3.0, 8.0}, {7.0, 2.0}]

    opts = [w: 10, h: 10, padding: [top: 1, bottom: 2, left: 3, right: 4]]
    {:ok, sparkline} = SparklineSvg.new(data, opts) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{3.0, 8.0}, {6.0, 1.0}]
  end

  test "valid datapoints" do
    {:ok, sparkline} = SparklineSvg.new([1, 2]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    {:ok, sparkline} = SparklineSvg.new([{1, 1}, {2, 2}]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    {:ok, sparkline} = SparklineSvg.new([{-1, 1}, {0, 2}]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    {:ok, sparkline} = SparklineSvg.new([{1.1, 1}, {1.2, 2}]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    data = [{1_704_877_202, 1}, {1_704_877_203, 2}]
    {:ok, sparkline} = SparklineSvg.new(data) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    data = [{Time.utc_now(), 1}, {Time.utc_now() |> Time.add(1, :second), 2}]
    {:ok, sparkline} = SparklineSvg.new(data) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    data = [{Date.utc_today(), 1}, {Date.utc_today() |> Date.add(1), 2}]
    {:ok, sparkline} = SparklineSvg.new(data) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    data = [{DateTime.utc_now(), 1}, {DateTime.utc_now() |> DateTime.add(1, :second), 2}]
    {:ok, sparkline} = SparklineSvg.new(data) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    data = [
      {NaiveDateTime.utc_now(), 1},
      {NaiveDateTime.utc_now() |> NaiveDateTime.add(1, :second), 2}
    ]

    {:ok, sparkline} = SparklineSvg.new(data) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]
  end

  test "valid order datapoints sort asc" do
    data = [{~D[2021-01-02], 1}, {~D[2021-01-01], 2}]
    {:ok, sparkline} = SparklineSvg.new(data, sort: :asc) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 2.0}, {198.0, 48.0}]

    data = [{~D[2021-01-01], 2}, {~D[2021-01-02], 1}]
    {:ok, sparkline} = SparklineSvg.new(data, sort: :asc) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 2.0}, {198.0, 48.0}]
  end

  test "valid datapoints with sort desc" do
    data = [{~D[2021-01-02], 1}, {~D[2021-01-01], 2}]
    {:ok, sparkline} = SparklineSvg.new(data, sort: :desc) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    data = [{~D[2021-01-01], 2}, {~D[2021-01-02], 1}]
    {:ok, sparkline} = SparklineSvg.new(data, sort: :desc) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]
  end

  test "valid order datapoints sort none" do
    data = [{~D[2021-01-02], 1}, {~D[2021-01-01], 2}]
    {:ok, sparkline} = SparklineSvg.new(data, sort: :none) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 48.0}, {198.0, 2.0}]

    data = [{~D[2021-01-01], 2}, {~D[2021-01-02], 1}]
    {:ok, sparkline} = SparklineSvg.new(data, sort: :none) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 2.0}, {198.0, 48.0}]
  end

  test "two same points" do
    {:ok, sparkline} = SparklineSvg.new([{1, 0}, {1, 2}]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{100.0, 25.0}]
  end

  test "with only zeros as values" do
    {:ok, sparkline} = SparklineSvg.new([{1, 0}, {2, 0}]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{2.0, 25.0}, {198.0, 25.0}]
  end

  test "with one value datapoints" do
    {:ok, sparkline} = SparklineSvg.new([1]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{100.0, 25.0}]

    {:ok, sparkline} = SparklineSvg.new([{5, 1}]) |> SparklineSvg.dry_run()
    assert sparkline.datapoints == [{100.0, 25.0}]
  end

  test "to_svg!/1 error handling" do
    assert_raise SparklineSvg.Error, "invalid_x_type", fn ->
      SparklineSvg.new([{"a", 1}, {"b", 2}]) |> SparklineSvg.to_svg!()
    end
  end

  test "as_data_uri/1" do
    assert [{1, 1}, {2, 2}]
           |> SparklineSvg.new()
           |> SparklineSvg.show_line()
           |> SparklineSvg.to_svg!()
           |> SparklineSvg.as_data_uri() ==
             "data:image/svg+xml;base64,PHN2ZyBoZWlnaHQ9IjEwMCUiIHZpZXdCb3g9IjAgMCAyMDAgNTAiIHdpZHRoPSIxMDAlIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxwYXRoIGQ9Ik0yLjAsNDguMEMzMS40LDQxLjEgMTY4LjYsOC45IDE5OC4wLDIuMCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIwLjI1IiAvPjwvc3ZnPg=="
  end
end
