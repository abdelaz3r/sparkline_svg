defmodule Sparkline.Marker do
  @moduledoc false

  @typedoc false
  @type marker_opts :: %{}

  @typedoc false
  @type t :: %__MODULE__{
          position: nil,
          options: marker_opts
        }
  @enforce_keys [:position, :options]
  defstruct [:position, :options]
end
