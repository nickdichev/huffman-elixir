defmodule Huffman do
  alias Huffman.Counter
  @moduledoc false

  @type filename() :: binary()

  @spec compress(filename()) :: map()
  def compress(filename) do
    filename
    |> File.stream!()
    |> Counter.count()
  end
end
