# Sparkline

**TODO: add cover IMAGE**

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

### A cyan sparkline with a line, area, and markers

``` elixir
# Data source
data = [4, 4, 6, 3, 2, 1, 3, 5, 7, 7, 7, 6, 9, 11, 11, 5, 7, 6, 9, 19, 19, 20, 21, 20, 17, 20, 19, 17]

# Arbitrary marker and marker area
marker = 25
marker_area = {10, 15}

data
|> Sparkline.new(smoothing: 0.05)
|> Sparkline.show_line(color: "rgba(6, 182, 212, 0.5)", width: 0.4)
|> Sparkline.show_area(color: "rgba(6, 182, 212, 0.2)")
|> Sparkline.add_marker(marker, stroke_color: "rgba(236, 72, 153, 0.8)", stroke_width: 0.4)
|> Sparkline.add_marker(marker_area, stroke_color: "rgba(236, 72, 153, 0.4)", stroke_width: 0.4, fill_color: "rgba(236, 72, 153, 0.2)")
|> Sparkline.to_svg!()
```

<div style="padding: 10px 6px; margin-bottom: 24px; border: solid 1px #ded7d7; border-radius: 10px; background: #ffffff;">
  <svg width="100%" height="100%" viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,41.1C2.363,41.1 8.533,41.33 9.259,41.1C9.985,40.87 15.793,36.385 16.519,36.5C17.244,36.615 23.052,42.94 23.778,43.4C24.504,43.86 30.311,45.47 31.037,45.7C31.763,45.93 37.57,48.115 38.296,48.0C39.022,47.885 44.83,43.86 45.556,43.4C46.281,42.94 52.089,39.26 52.815,38.8C53.541,38.34 59.348,34.43 60.074,34.2C60.8,33.97 66.607,34.2 67.333,34.2C68.059,34.2 73.867,34.085 74.593,34.2C75.319,34.315 81.126,36.73 81.852,36.5C82.578,36.27 88.385,30.175 89.111,29.6C89.837,29.025 95.644,25.23 96.37,25.0C97.096,24.77 102.904,24.31 103.63,25.0C104.356,25.69 110.163,38.34 110.889,38.8C111.615,39.26 117.422,34.315 118.148,34.2C118.874,34.085 124.681,36.73 125.407,36.5C126.133,36.27 131.941,31.095 132.667,29.6C133.393,28.105 139.2,7.75 139.926,6.6C140.652,5.45 146.459,6.715 147.185,6.6C147.911,6.485 153.719,4.53 154.444,4.3C155.17,4.07 160.978,2.0 161.704,2.0C162.43,2.0 168.237,3.84 168.963,4.3C169.689,4.76 175.496,11.2 176.222,11.2C176.948,11.2 182.756,4.53 183.481,4.3C184.207,4.07 190.015,6.255 190.741,6.6C191.467,6.945 197.637,10.97 198.0,11.2V50H2.0Z" fill="rgba(6, 182, 212, 0.2)" stroke="none" /><path d="M2.0,41.1C2.363,41.1 8.533,41.33 9.259,41.1C9.985,40.87 15.793,36.385 16.519,36.5C17.244,36.615 23.052,42.94 23.778,43.4C24.504,43.86 30.311,45.47 31.037,45.7C31.763,45.93 37.57,48.115 38.296,48.0C39.022,47.885 44.83,43.86 45.556,43.4C46.281,42.94 52.089,39.26 52.815,38.8C53.541,38.34 59.348,34.43 60.074,34.2C60.8,33.97 66.607,34.2 67.333,34.2C68.059,34.2 73.867,34.085 74.593,34.2C75.319,34.315 81.126,36.73 81.852,36.5C82.578,36.27 88.385,30.175 89.111,29.6C89.837,29.025 95.644,25.23 96.37,25.0C97.096,24.77 102.904,24.31 103.63,25.0C104.356,25.69 110.163,38.34 110.889,38.8C111.615,39.26 117.422,34.315 118.148,34.2C118.874,34.085 124.681,36.73 125.407,36.5C126.133,36.27 131.941,31.095 132.667,29.6C133.393,28.105 139.2,7.75 139.926,6.6C140.652,5.45 146.459,6.715 147.185,6.6C147.911,6.485 153.719,4.53 154.444,4.3C155.17,4.07 160.978,2.0 161.704,2.0C162.43,2.0 168.237,3.84 168.963,4.3C169.689,4.76 175.496,11.2 176.222,11.2C176.948,11.2 182.756,4.53 183.481,4.3C184.207,4.07 190.015,6.255 190.741,6.6C191.467,6.945 197.637,10.97 198.0,11.2" fill="none" stroke="rgba(6, 182, 212, 0.5)" stroke-width="0.4" /><path d="M183.481,0.0V50" fill="none" stroke="rgba(236, 72, 153, 0.8)" stroke-width="0.4" /><rect x="74.593" y="-0.4" width="36.296" height="50.8" fill="rgba(236, 72, 153, 0.2)" stroke="rgba(236, 72, 153, 0.4)" stroke-width="0.4" /></svg>
</div>

### A green sparkline, on dark background, with a line, and area

``` elixir
# Data source
[4, 4, 6, 3, 2, 1, 3, 5, 7, 7, 7, 6, 9, 11, 11, 5, 7, 6, 9, 19, 19, 20, 21, 20, 17, 20, 19, 17]
|> Sparkline.new(width: 200, height: 30, smoothing: 0)
|> Sparkline.show_line(color: "rgba(40, 255, 118, 0.8)", width: 0.4)
|> Sparkline.show_area(color: "rgba(40, 255, 118, 0.4)")
|> Sparkline.to_svg!()
```

<div style="padding: 10px 6px; margin-bottom: 24px; border: solid 1px #0a101c; border-radius: 10px; background: #030812;">
  <svg width="100%" height="100%" viewBox="0 0 200 30" xmlns="http://www.w3.org/2000/svg"><path d="M2.0,24.1C2.0,24.1 9.259,24.1 9.259,24.1C9.259,24.1 16.519,21.5 16.519,21.5C16.519,21.5 23.778,25.4 23.778,25.4C23.778,25.4 31.037,26.7 31.037,26.7C31.037,26.7 38.296,28.0 38.296,28.0C38.296,28.0 45.556,25.4 45.556,25.4C45.556,25.4 52.815,22.8 52.815,22.8C52.815,22.8 60.074,20.2 60.074,20.2C60.074,20.2 67.333,20.2 67.333,20.2C67.333,20.2 74.593,20.2 74.593,20.2C74.593,20.2 81.852,21.5 81.852,21.5C81.852,21.5 89.111,17.6 89.111,17.6C89.111,17.6 96.37,15.0 96.37,15.0C96.37,15.0 103.63,15.0 103.63,15.0C103.63,15.0 110.889,22.8 110.889,22.8C110.889,22.8 118.148,20.2 118.148,20.2C118.148,20.2 125.407,21.5 125.407,21.5C125.407,21.5 132.667,17.6 132.667,17.6C132.667,17.6 139.926,4.6 139.926,4.6C139.926,4.6 147.185,4.6 147.185,4.6C147.185,4.6 154.444,3.3 154.444,3.3C154.444,3.3 161.704,2.0 161.704,2.0C161.704,2.0 168.963,3.3 168.963,3.3C168.963,3.3 176.222,7.2 176.222,7.2C176.222,7.2 183.481,3.3 183.481,3.3C183.481,3.3 190.741,4.6 190.741,4.6C190.741,4.6 198.0,7.2 198.0,7.2V30H2.0Z" fill="rgba(40, 255, 118, 0.4)" stroke="none" /><path d="M2.0,24.1C2.0,24.1 9.259,24.1 9.259,24.1C9.259,24.1 16.519,21.5 16.519,21.5C16.519,21.5 23.778,25.4 23.778,25.4C23.778,25.4 31.037,26.7 31.037,26.7C31.037,26.7 38.296,28.0 38.296,28.0C38.296,28.0 45.556,25.4 45.556,25.4C45.556,25.4 52.815,22.8 52.815,22.8C52.815,22.8 60.074,20.2 60.074,20.2C60.074,20.2 67.333,20.2 67.333,20.2C67.333,20.2 74.593,20.2 74.593,20.2C74.593,20.2 81.852,21.5 81.852,21.5C81.852,21.5 89.111,17.6 89.111,17.6C89.111,17.6 96.37,15.0 96.37,15.0C96.37,15.0 103.63,15.0 103.63,15.0C103.63,15.0 110.889,22.8 110.889,22.8C110.889,22.8 118.148,20.2 118.148,20.2C118.148,20.2 125.407,21.5 125.407,21.5C125.407,21.5 132.667,17.6 132.667,17.6C132.667,17.6 139.926,4.6 139.926,4.6C139.926,4.6 147.185,4.6 147.185,4.6C147.185,4.6 154.444,3.3 154.444,3.3C154.444,3.3 161.704,2.0 161.704,2.0C161.704,2.0 168.963,3.3 168.963,3.3C168.963,3.3 176.222,7.2 176.222,7.2C176.222,7.2 183.481,3.3 183.481,3.3C183.481,3.3 190.741,4.6 190.741,4.6C190.741,4.6 198.0,7.2 198.0,7.2" fill="none" stroke="rgba(40, 255, 118, 0.8)" stroke-width="0.4" /></svg>
</div>
