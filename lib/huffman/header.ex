defmodule Huffman.Header do
  @moduledoc false

  @spec get_header(any()) :: {bitstring(), non_neg_integer()}
  def get_header(char_counts) do
    # We will use `term_to_binary/2` to generate our header. The header will be used for
    # decompression. The header will be read and the Huffman tree can be recreated.
    binary_term = :erlang.term_to_binary(char_counts, compressed: 9)
    term_len = byte_size(binary_term)
    {binary_term, term_len}
  end

  @spec from_binary(binary()) :: any()
  def from_binary(binary) do
    :erlang.binary_to_term(binary)
  end
end
