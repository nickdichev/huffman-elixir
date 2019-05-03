defmodule Huffman.IOHelper do
  @moduledoc false

  @doc """
  Pad a list of bitstrings into a list of binaries and the remaining output. We need to format the compressed
  data (which are all bitstring) into binaries so we can write it. The leftover buffer should have the EOF characater
  appended and padded to a binary.

  Note that we need to use bitstrings when creating the buffered binaries here since we are working with
  bitstrings. The typical binary concatenation operator <> won't work since we have bitstrings. To see why
  try expanding the <> macro:

  ```
  # iex(24)> quote(do: <<1::size(1)>> <> <<0::size(1)>>) |> Macro.expand(__ENV__) |> Macro.to_string()
  # "<<(<<1::size(1)>>::binary), (<<0::size(1)>>::binary)>>"
  ```

  ## Examples
    iex> Huffman.IOHelper.buffer_output([<<4, 1::size(2), 0::size(2)>>], <<>>, [])
    {[[], 4], <<4::size(4)>>}
  """
  @spec buffer_output([bitstring(), ...] | [], bitstring(), iolist()) :: {iolist(), bitstring()}
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

  @doc """
  Check if there is a full byte on the front of the buffer, if so return that byte and the "rest"

  ## Examples
    iex> Huffman.IOHelper.completed_byte(<<4, 1::size(1)>>)
    {4, <<1::size(1)>>}

    iex> Huffman.IOHelper.completed_byte(<<1::size(1)>>)
    {nil, nil}
  """
  @spec completed_byte(bitstring()) :: {byte(), bitstring()} | {nil, nil}
  def completed_byte(<<byte::size(8), rest::bitstring>>), do: {byte, rest}
  def completed_byte(_), do: {nil, nil}

  # Replace a list of characters with their encodings
  @doc """
  Replace a list of characters with their encodings.

  ## Examples
    iex> Huffman.IOHelper.encode_characters(["a", "b"], %{"a" => <<1::size(2)>>, "b" => <<0::size(2)>>})
    [<<1::size(2)>>, <<0::size(2)>>]
  """
  @spec encode_characters(iolist(), map()) :: iolist()
  def encode_characters(iolist, encodings), do: Enum.map(iolist, &Map.get(encodings, &1))

  @doc """
  Pads a bitstring into a binary if required. The bistring is padded with zeros in the least significant
  digits of the bitstring, to the nearest multiple of 8 bits.

  ## Examples
    iex> Huffman.IOHelper.pad_bitstring(<<3, 4>>)
    <<3, 4>>

    iex> Huffman.IOHelper.pad_bitstring(<<3::size(3)>>)
    <<3::size(3), 0::size(5)>>
  """
  @spec pad_bitstring(bitstring()) :: bitstring()
  def pad_bitstring(bits) when is_binary(bits), do: bits

  def pad_bitstring(bits) do
    size = bit_size(bits)
    pad_len = (8 * ceil(size / 8)) - size
    <<bits::bitstring, 0::size(pad_len)>>
  end

end
