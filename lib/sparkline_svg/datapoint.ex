defmodule SparklineSvg.Datapoint do
  @moduledoc false

  alias SparklineSvg.Type
  alias SparklineSvg.Datapoint

  @typedoc false
  @type points :: list(Datapoint.t())

  @typedoc false
  @type t :: %Datapoint{
          source: SparklineSvg.datapoints(),
          computed: points()
        }
  @enforce_keys [:source, :computed]
  defstruct [:source, :computed]

  @spec clean(SparklineSvg.datapoints(), SparklineSvg.window(), SparklineSvg.sort_options()) ::
          {:ok, Datapoint.points(), SparklineSvg.window(), SparklineSvg.x()} | {:error, atom()}
  def clean(datapoints, window, sort) do
    {datapoints, type} = ensure_datapoint_type(datapoints)

    with datapoints when is_list(datapoints) <- datapoints,
         {:ok, min} <- Type.cast_window(window.min, type),
         {:ok, max} <- Type.cast_window(window.max, type) do
      window = %{min: min, max: max}

      datapoints =
        datapoints
        |> maybe_window(window)
        |> Enum.uniq_by(fn %{computed: {x, _}} -> x end)

      datapoints =
        case sort do
          :asc -> Enum.sort_by(datapoints, fn %{computed: {x, _}} -> x end)
          :desc -> Enum.sort_by(datapoints, fn %{computed: {x, _}} -> x end, :desc)
          :none -> Enum.reverse(datapoints)
        end

      {:ok, datapoints, window, type}
    end
  end

  @spec ensure_datapoint_type(SparklineSvg.datapoints()) ::
          {Datapoint.points(), SparklineSvg.x()} | {{:error, atom()}, SparklineSvg.x()}
  defp ensure_datapoint_type([{_x, _y} | _] = datapoints) do
    Enum.reduce_while(datapoints, {[], nil}, fn
      {sx, sy}, {datapoints, type} ->
        with {:ok, cx, type} <- Type.cast_x(sx, type),
             {:ok, cy} <- Type.cast_y(sy) do
          point = %Datapoint{source: {sx, sy}, computed: {cx, cy}}
          {:cont, {[point | datapoints], type}}
        else
          {:error, reason} -> {:halt, {{:error, reason}, type}}
        end

      _only_y, {_datapoints, type} ->
        {:halt, {{:error, :mixed_datapoints_types}, type}}
    end)
  end

  defp ensure_datapoint_type(datapoints) do
    datapoints =
      datapoints
      |> Enum.with_index()
      |> Enum.reduce_while([], fn
        {{_, _}, _index}, _datapoints ->
          {:halt, {:error, :mixed_datapoints_types}}

        {sy, index}, datapoints ->
          case Type.cast_y(sy) do
            {:ok, cy} ->
              point = %Datapoint{source: {index, sy}, computed: {index, cy}}
              {:cont, [point | datapoints]}

            {:error, reason} ->
              {:halt, {:error, reason}}
          end
      end)

    {datapoints, :number}
  end

  @spec maybe_window(Datapoint.points(), SparklineSvg.window()) :: Datapoint.points()
  def maybe_window(datapoints, %{min: :auto, max: :auto}) do
    datapoints
  end

  def maybe_window(datapoints, %{min: min, max: :auto}) do
    Enum.filter(datapoints, fn %{computed: {x, _}} -> x >= min end)
  end

  def maybe_window(datapoints, %{min: :auto, max: max}) do
    Enum.filter(datapoints, fn %{computed: {x, _}} -> x <= max end)
  end

  def maybe_window(datapoints, %{min: min, max: max}) do
    Enum.filter(datapoints, fn %{computed: {x, _}} -> x >= min and x <= max end)
  end
end
