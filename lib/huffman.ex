defmodule Huffman do
  alias Huffman.Counter
  @moduledoc false

  @spec compress(binary()) :: map()
  def compress(filename) do
    filename
    |> Counter.count()
  end
end
