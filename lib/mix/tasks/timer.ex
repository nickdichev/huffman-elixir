defmodule Mix.Tasks.Timer do
  use Mix.Task

  @shortdoc "Times how long it takes to compress"
  def run([path]) do
    start_time = System.monotonic_time(:millisecond)
    _ = Huffman.compress_file(path)
    end_time = System.monotonic_time(:millisecond)
    delta = end_time - start_time

    IO.puts("Took #{delta} milliseconds to compress #{Path.basename(path)}")
  end
end
