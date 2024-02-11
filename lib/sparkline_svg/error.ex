defmodule SparklineSvg.Error do
  @moduledoc """
  An exception raised when datapoints, markers, or options are invalid.

  `SparklineSvg.Error` exceptions have a single field, :message (a String.t/0), which is public.
  """

  defexception [:message]
end
