defmodule Huffman.Header do
  @moduledoc false

  @doc """
  Converts a given character count map into a erlang term binary. This data is the header that
  is used for decompression.
  """
  @spec get_header(any()) :: {bitstring(), non_neg_integer()}
  def get_header(char_counts) do
    # We will use `term_to_binary/2` to generate our header. The header will be used for
    # decompression. The header will be read and the Huffman tree can be recreated.
    binary_term = :erlang.term_to_binary(char_counts, compressed: 9)
    term_len = byte_size(binary_term)
    {binary_term, term_len}
  end

  @doc """
  Converts an erlang term binary to an term. We expect this to recreate the character map
  when we need to decompress a file that was compressed by this program.
  """
  @spec from_binary(binary()) :: any()
  def from_binary(binary) do
    :erlang.binary_to_term(binary)
  end
end
