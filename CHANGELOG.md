# Changelog

## v0.5.0 (2024-03-25)

  * Enhancements
    * Support `:sort` option to control data sorting
      ([#39](https://github.com/abdelaz3r/sparkline_svg/pull/39))
    * Add `set_x_window/2` function with `:min` and `:max` options 
      ([#33](https://github.com/abdelaz3r/sparkline_svg/pull/33))
    * Improve links in documentation
  * Bug fixes
    * Fix link in documentation
      ([#40](https://github.com/abdelaz3r/sparkline_svg/pull/40))
      ([Juan Barrios](https://github.com/03juan))

## v0.4.0 (2024-03-05)

  * Enhancements
    * Expose number `:precision` through general options
      ([#35](https://github.com/abdelaz3r/sparkline_svg/pull/35))
    * Support `percentile/1` reference line and custom reference lines
      ([#37](https://github.com/abdelaz3r/sparkline_svg/pull/37))
      ([victor felder](https://github.com/vhf))

## v0.3.1 (2024-03-05)

  * Bug fixes
    * Fix crashes when only one value is given

## v0.3.0 (2024-02-27)

  * Enhancements
    * Support `:padding` option specifying padding for specific side

## v0.2.0 (2024-02-21)

  * Enhancements
    * Support `:max` reference line
    * Support `:min` reference line
    * Support `:avg` reference line
    * Support `:median` reference line
    * Support `:dasharray` option for lines, markers, and reference lines

## v0.1.1 (2024-02-12)

  * Bug fixes
    * Fix typespec of `t:SparklineSvg.marker/0` and `t:SparklineSvg.markers/0`

## v0.1.0 (2024-02-11)

  * Enhancements
    * First public release
    * Support line, dots, and area
    * Support markers
