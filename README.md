# Sparkline

[IMAGE]

`Sparkline` is an Elixir library to generate SVG sparkline charts.

**TODO: Link to documentation on hex**

## Overview

A [sparkline](https://en.wikipedia.org/wiki/Sparkline) is a small, simple chart that is drawn
without axes or coordinates. It presents the general shape of the variation of a dataset at a
glance.

`Sparkline` allows you to create a sparkline chart from various data shapes and show the dots,
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

`Sparkline` allows you to customize the chart showing or hiding the dots, the line, and the area
under the line. There are two ways to customize the chart:
- Using the options like color or width.
- Using the CSS classes option to give classes to SVG elements and then using CSS to style them.

## Status

This library is currently under active development and it’s API is likely to change.

## Installation

The package can be installed by adding `:sparkline` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sparkline, "~> 0.1.0"}
  ]
end
```

## Usage example

``` elixir
# Datapoints and general options
datapoints = [1, 3, 2, 2, 5]
options = [width: 100, height: 40]

# A very simple line chart
sparkline = Sparkline.new(datapoints, options)

# Display what you want
line_options = [width: 0.25, color: "black"]
sparkline = Sparkline.show_line(sparkline, line_options)

# Render the chart to an SVG string
{:ok, svg} = Sparkline.to_svg(sparkline)
```

## Examples

**TODO: Put 2-3 examples with images and code**
