defmodule SparklineTest do
  use ExUnit.Case, async: true

  setup do
    data_uri =
      "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIgogIHZpZXdCb3g9IjAgMCAyMDAgMTAwIgogIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgCiAgPHBhdGgKICBkPSJNNi4wLDk0LjBDNDMuNiw3Ni40IDE1Ni40LDIzLjYgMTk0LjAsNi4wIgogIGZpbGw9Im5vbmUiCiAgc3Ryb2tlPSJibGFjayIKICBzdHJva2Utd2lkdGg9IjAuMjUiIC8+CgogIDxjaXJjbGUKICBjeD0iNi4wIgogIGN5PSI5NC4wIgogIHI9IjEiCiAgZmlsbD0iYmxhY2siIC8+CjxjaXJjbGUKICBjeD0iMTk0LjAiCiAgY3k9IjYuMCIKICByPSIxIgogIGZpbGw9ImJsYWNrIiAvPgoKPC9zdmc+Cg=="

    %{data_uri: data_uri}
  end

  test "as_data_uri/1", context do
    data_uri =
      [{1, 1}, {2, 2}]
      |> Sparkline.Line.to_svg!()
      |> Sparkline.as_data_uri()

    assert data_uri == context.data_uri
  end
end
