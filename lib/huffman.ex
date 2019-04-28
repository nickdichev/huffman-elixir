defmodule Huffman do
  alias Huffman.{Counter, PriorityQueue, Tree}
  @moduledoc false

  @spec compress(binary()) :: map()
  def compress_file(filename) when is_binary(filename) do
    compressed_data =
      filename
      |> File.stream!()
      |> compress()

    File.write!(filename <> ".hf", compressed_data)
  end

  def compress(bin) when is_binary(bin), do: compress([bin])

  def compress(iolist) do
    # Get the character counts for the input. Used to write the header and to build the tree
    char_counts = Counter.count(iolist)

    # We will use `term_to_binary/2` to generate our header. The header will be used for
    # decompression. The header will be read and the Huffman tree can be recreated.
    header_data = :erlang.term_to_binary(char_counts, compressed: 9)
    header_length = byte_size(header_data)

    compressed_body =
      char_counts
      |> get_huffman_tree()
      |> Tree.inorder()
      |> compressed_output(iolist)
      |> Stream.flat_map(&List.flatten/1)
      |> Enum.to_list()
      |> buffer_output(<<>>, [])
  end

  # Create a Huffman tree from a character counts map
  defp get_huffman_tree(char_counts) do
    char_counts
    |> PriorityQueue.from_map()
    |> Tree.from_priority_queue()
  end

  # Convert some input into its Huffman encoded representation line-by-line
  defp compressed_output(encodings, iodata) do
    iodata
    |> Stream.map(&String.split(&1, ""))
    |> Stream.map(&Enum.filter(&1, fn x -> x != "" end))
    |> Stream.map(&encode_characters(&1, encodings))
  end

  # Replace a list of characters with their encodings
  defp encode_characters(iodata, encodings), do: Enum.map(iodata, &Map.get(encodings, &1))

  # Format our list of improperly formatted binaries
  # iex(24)> quote(do: <<1::size(1)>> <> <<0::size(1)>>) |> Macro.expand(__ENV__) |> Macro.to_string()
  # "<<(<<1::size(1)>>::binary), (<<0::size(1)>>::binary)>>"
  # this doesn't work because we need to operate on bitstrings
  defp buffer_output([head | tail], buffer, iolist) do
    # Concatenate whatever encoding is next
    buffer = <<buffer::bitstring, head::bitstring>>

    # Lets check if we've completed a full byte of output
    # If we have, update the iolist accumulator that is the "final" output
    {byte, rest} = completed_byte(buffer)
    {buffer, iolist} =
      # There's a completed byte on the front of the buffer, append it into the iolist
      # and use the rest of the buffer in the next recursion
      if byte != nil and rest != nil do
        {rest, [iolist, byte]}
      # There's an uncompleted byte on the front of the buffer,
      # use the current buffer and iolist for the next recursion
      else
        {buffer, iolist}
      end

    # Keep the recursion going
    buffer_output(tail, buffer, iolist)
  end

  # Base of the recursion, we've processed every character
  defp buffer_output([], buffer, iolist) do
    buffer_size = bit_size(buffer)

    # We need to check if there's anything left in the buffer
    final_byte =
      if rem(buffer_size, 8) == 0 do
        # We got lucky and the leftover buffer is a full byte
        buffer
      else
        # We need to pad the leftover buffer to a full byte
        pad_len = 8 - buffer_size
        <<buffer::bitstring, 0::size(pad_len)>>
      end

    [iolist, final_byte]
  end

  # Check if there's a full byte on the front of the buffer, if so return that byte, and the "rest"
  defp completed_byte(<<byte::size(8), rest::bitstring>>), do: {byte, rest}
  defp completed_byte(_), do: {nil, nil}
end
