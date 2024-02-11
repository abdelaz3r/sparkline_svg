defmodule SparklineSvgMarkerTest do
  use ExUnit.Case, async: true

  test "to_svg/2 with invalid marker" do
    data_number = [{1, 1}, {2, 2}]
    data_time = [{Time.utc_now(), 1}, {Time.utc_now() |> Time.add(1, :second), 2}]

    assert SparklineSvg.new(data_number) |> SparklineSvg.add_marker("b") |> SparklineSvg.to_svg() ==
             {:error, :invalid_x_type}

    assert SparklineSvg.new(data_number)
           |> SparklineSvg.add_marker({"b", 1})
           |> SparklineSvg.to_svg() ==
             {:error, :invalid_x_type}

    assert SparklineSvg.new(data_number)
           |> SparklineSvg.add_marker(DateTime.utc_now())
           |> SparklineSvg.to_svg() ==
             {:error, :mixed_datapoints_types}

    assert SparklineSvg.new(data_time) |> SparklineSvg.add_marker(1) |> SparklineSvg.to_svg() ==
             {:error, :mixed_datapoints_types}
  end

  test "to_svg/2 with valid marker" do
    data_number = [{1, 1}, {2, 2}]
    data_time = [{Time.utc_now(), 1}, {Time.utc_now() |> Time.add(1, :second), 2}]

    assert SparklineSvg.new(data_number) |> SparklineSvg.add_marker(1) |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" fill="none" stroke="red" stroke-width="0.25" /></svg>'}

    assert SparklineSvg.new(data_number)
           |> SparklineSvg.add_marker({1, 2})
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><rect x="2.0" y="-0.25" width="196.0" height="50.5" fill="rgba(255, 0, 0, 0.1)" stroke="red" stroke-width="0.25" /></svg>'}

    assert SparklineSvg.new(data_time)
           |> SparklineSvg.add_marker(Time.utc_now())
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" fill="none" stroke="red" stroke-width="0.25" /></svg>'}
  end

  test "to_svg/2 with area markers in reversed order" do
    data_number = [{1, 1}, {2, 2}]

    assert SparklineSvg.new(data_number)
           |> SparklineSvg.add_marker({1, 2})
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><rect x="2.0" y="-0.25" width="196.0" height="50.5" fill="rgba(255, 0, 0, 0.1)" stroke="red" stroke-width="0.25" /></svg>'}

    assert SparklineSvg.new(data_number)
           |> SparklineSvg.add_marker({2, 1})
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><rect x="2.0" y="-0.25" width="196.0" height="50.5" fill="rgba(255, 0, 0, 0.1)" stroke="red" stroke-width="0.25" /></svg>'}
  end

  test "to_svg/2 with multiple markers" do
    assert SparklineSvg.new([{1, 1}, {2, 2}])
           |> SparklineSvg.add_marker(1)
           |> SparklineSvg.add_marker(2)
           |> SparklineSvg.add_marker({1, 2})
           |> SparklineSvg.to_svg() ==
             {:ok,
              ~S'<svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,0.0V50" fill="none" stroke="red" stroke-width="0.25" /><path d="M198.0,0.0V50" fill="none" stroke="red" stroke-width="0.25" /><rect x="2.0" y="-0.25" width="196.0" height="50.5" fill="rgba(255, 0, 0, 0.1)" stroke="red" stroke-width="0.25" /></svg>'}
  end
end
