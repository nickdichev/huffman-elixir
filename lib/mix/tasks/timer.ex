defmodule Mix.Tasks.Timer do
  use Mix.Task

  @shortdoc "Times how long it takes to compress"
  def run([path, with_flow?]) do
    counter_opts = counter_opts(with_flow?)

    start_time = System.monotonic_time(:millisecond)
    _ = Huffman.compress_file(path, counter_opts)
    end_time = System.monotonic_time(:millisecond)
    delta = end_time - start_time

    IO.puts("Took #{delta} milliseconds to compress #{Path.basename(path)}")
  end

  defp counter_opts("true"), do: [flow?: true]
  defp counter_opts(_), do: []
end
