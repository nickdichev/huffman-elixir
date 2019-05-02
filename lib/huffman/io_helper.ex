defmodule Huffman.IOHelper do
  @moduledoc false

  # Convert some input into its Huffman encoded representation line-by-line
  def compressed_output(encodings, iodata) do
    iodata
    |> Stream.map(&String.split(&1, ""))
    |> Stream.map(&Enum.filter(&1, fn x -> x != "" end))
    |> Stream.map(&encode_characters(&1, encodings))
    |> Stream.flat_map(&List.flatten/1)
  end

  # Format our list of improperly formatted binaries
  # iex(24)> quote(do: <<1::size(1)>> <> <<0::size(1)>>) |> Macro.expand(__ENV__) |> Macro.to_string()
  # "<<(<<1::size(1)>>::binary), (<<0::size(1)>>::binary)>>"
  # this doesn't work because we need to operate on bitstrings
  def buffer_output([head | tail], buffer, iolist) do
    # Concatenate whatever encoding is next
    buffer = <<buffer::bitstring, head::bitstring>>

    # Lets check if we've completed a full byte of output
    # If we have, update the iolist accumulator that is the "final" output
    {byte, rest} = completed_byte(buffer)
    {buffer, iolist} =
      if byte != nil and rest != nil do
        # There's a completed byte on the front of the buffer, append it into the iolist
        # and use the rest of the buffer in the next recursion
        {rest, [iolist, byte]}
      else
        # There's an uncompleted byte on the front of the buffer,
        # use the current buffer and iolist for the next recursion
        {buffer, iolist}
      end

    # Keep the recursion going
    buffer_output(tail, buffer, iolist)
  end

  # Base of the recursion, we've processed every character
  def buffer_output([], buffer, iolist), do: {iolist, buffer}

  # Check if there's a full byte on the front of the buffer, if so return that byte, and the "rest"
  def completed_byte(<<byte::size(8), rest::bitstring>>), do: {byte, rest}
  def completed_byte(_), do: {nil, nil}

  # Replace a list of characters with their encodings
  def encode_characters(iodata, encodings), do: Enum.map(iodata, &Map.get(encodings, &1))

  def pad_bitstring(bits) when is_binary(bits), do: bits

  def pad_bitstring(bits) do
    size = bit_size(bits)
    pad_len = (8 * ceil(size / 8)) - size
    <<bits::bitstring, 0::size(pad_len)>>
  end

   def decompressed_output(_rest, _root, %{left: nil, right: nil, character: <<255>>}, iolist) do
     iolist
   end

  def decompressed_output(rest, root, %{left: nil, right: nil} = node, iolist) do
    decompressed_output(rest, root, root, [iolist, node.character])
  end

  def decompressed_output(<<1::size(1), rest::bitstring>>, root, node, iolist) do
    decompressed_output(rest, root, node.right, iolist)
  end

  def decompressed_output(<<0::size(1), rest::bitstring>>, root, node, iolist) do
    decompressed_output(rest, root, node.left, iolist)
  end
end
