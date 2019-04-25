defmodule Huffman do
  alias Huffman.Counter
  @moduledoc false

  def compress(filename) do
    filename
    |> Counter.count()
  end
end
