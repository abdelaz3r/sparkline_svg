# Sparkline SVG

![Sparkline SVG](https://raw.githubusercontent.com/abdelaz3r/sparkline_svg/main/documents/assets/cover.png)

**Sparkline SVG** is simple, zero-dependency, Elixir library to generate SVG sparkline charts.

Documentation can be found at [https://hexdocs.pm/packages/sparkline_svg](https://hexdocs.pm/packages/sparkline_svg).

## Overview

A [sparkline](https://en.wikipedia.org/wiki/Sparkline) is a small, simple chart that is drawn
without axes or coordinates. It presents the general shape of the variation of a dataset at a
glance.

Sparkline SVG allows you to create a sparkline chart from various data shapes and show the dots,
the line, and the area under the line. You can also add markers to the chart to highlight
specific spots.

### Datapoints

Datapoints are the values that will be used to draw the chart. They can be:
- A **list of numbers**, where each number is a value for the y axis.
- A **list of tuples** with two values. The first value is the x axis and the second value is
  the y axis.

### Markers

Markers are used to highlight specific spots on the chart. There are two types of markers:
- A single marker that will be rendered as a vertical line.
- A range marker that will be rendered as a rectangle.

### Customization

Sparkline SVG allows you to customize the chart showing or hiding the dots, the line, and the area
under the line. There are two ways to customize the chart:
- Using the options like color or width.
- Using the CSS classes option to give classes to SVG elements and then using CSS to style them.

## Status

This library is currently under active development and it’s API is likely to change.

## Installation

The package can be installed by adding `:sparkline_svg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sparkline_svg, "~> 0.1.0"}
  ]
end
```

## Usage example

``` elixir
# Datapoints and general options
datapoints = [1, 3, 2, 2, 5]
options = [width: 100, height: 40]

# A very simple line chart
sparkline = SparklineSvg.new(datapoints, options)

# Display what you want
line_options = [width: 0.25, color: "black"]
sparkline = SparklineSvg.show_line(sparkline, line_options)

# Render the chart to an SVG string
{:ok, svg} = SparklineSvg.to_svg(sparkline)
```

## Examples

### A cyan sparkline with a line, area, and markers

``` elixir
# Data source
data = [4, 4, 6, 3, 2, 1, 3, 5, 7, 7, 7, 6, 9, 11, 11, 5, 7, 6, 9, 19, 19, 20, 21, 20, 17, 20, 19, 17]

# Arbitrary marker and marker area
marker = 25
marker_area = {10, 15}

data
|> SparklineSvg.new(smoothing: 0.05)
|> SparklineSvg.show_line(color: "rgba(6, 182, 212, 0.5)", width: 0.4)
|> SparklineSvg.show_area(color: "rgba(6, 182, 212, 0.2)")
|> SparklineSvg.add_marker(marker, stroke_color: "rgba(236, 72, 153, 0.8)", stroke_width: 0.4)
|> SparklineSvg.add_marker(marker_area, stroke_color: "rgba(236, 72, 153, 0.4)", stroke_width: 0.4, fill_color: "rgba(236, 72, 153, 0.2)")
|> SparklineSvg.to_svg!()
```

![A cyan sparkline with a line, area, and markers](https://raw.githubusercontent.com/abdelaz3r/sparkline_svg/main/documents/assets/light-sparkline-example.png)

### A green sparkline, on dark background, with a line, and area

``` elixir
# Data source
[4, 4, 6, 3, 2, 1, 3, 5, 7, 7, 7, 6, 9, 11, 11, 5, 7, 6, 9, 19, 19, 20, 21, 20, 17, 20, 19, 17]
|> SparklineSvg.new(width: 200, height: 30, smoothing: 0)
|> SparklineSvg.show_line(color: "rgba(40, 255, 118, 0.8)", width: 0.4)
|> SparklineSvg.show_area(color: "rgba(40, 255, 118, 0.4)")
|> SparklineSvg.to_svg!()
```

![A green sparkline, on dark background, with a line, and area](https://raw.githubusercontent.com/abdelaz3r/sparkline_svg/main/documents/assets/dark-sparkline-example.png)
