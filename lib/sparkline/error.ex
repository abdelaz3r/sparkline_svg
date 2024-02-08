defmodule Sparkline.Error do
  @moduledoc """
  An exception raised when datapoints, markers, or options are invalid.

  `Sparkline.Error` exceptions have a single field, :message (a String.t/0), which is public.
  """

  defexception [:message]
end
