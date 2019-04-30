defmodule Huffman.IOHelper do
  @moduledoc false

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
  def buffer_output([], buffer, iolist) do
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
  def completed_byte(<<byte::size(8), rest::bitstring>>), do: {byte, rest}
  def completed_byte(_), do: {nil, nil}

  # Replace a list of characters with their encodings
  def encode_characters(iodata, encodings), do: Enum.map(iodata, &Map.get(encodings, &1))
end
