defmodule Huffman do
  alias Huffman.{Counter, Header, IOHelper, PriorityQueue, Tree}
  @moduledoc false

  @header_length 32
  @bits_per_byte 8

  @spec compress_file(binary()) :: :ok
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
    # We also need to add the EOF so we can get an encoding for it, and store it in the header
    char_counts =
      iolist
      |> Counter.count()
      |> Map.put(<<255>>, 1)

    # Generate the Huffman header that will be used for decompression
    {header, header_num_bytes} = Header.get_header(char_counts)

    # Generate the Huffman encodings from the character counts
    encodings =
      char_counts
      |> PriorityQueue.from_map()
      |> Tree.from_priority_queue()
      |> Tree.inorder()

    # Generate the compressed output from the encodings/input data
    {body, buffer} =
      encodings
      |> compressed_output(iolist)
      |> Enum.to_list()
      |> IOHelper.buffer_output(<<>>, [])

    # There might be something leftover in the buffer, lets grab that bitstring,
    # append the EOF, and pad if neccessary
    eof_encoding = Map.get(encodings, <<255>>)
    eof = IOHelper.pad_bitstring(<<buffer::bitstring, eof_encoding::bitstring>>)

    [<<header_num_bytes::size(@header_length)>>, header, body, eof]
  end

  # Convert some input into its Huffman encoded representation line-by-line
  defp compressed_output(encodings, iodata) do
    iodata
    |> Stream.map(&String.split(&1, ""))
    |> Stream.map(&Enum.filter(&1, fn x -> x != "" end))
    |> Stream.map(&IOHelper.encode_characters(&1, encodings))
    |> Stream.flat_map(&List.flatten/1)
  end

  @spec decompress_file(binary()) :: :ok
  def decompress_file(filename) do
    decompressed_data =
      filename
      |> File.read!()
      |> decompress()

    File.write!(filename <> ".orig", decompressed_data)
  end

  def decompress([header_bytes, header, iodata, eof] = iolist) when is_list(iolist) do
    body_binary = IO.iodata_to_binary(iodata)
    decompress(header_bytes <> header <> body_binary <> eof)
  end

  def decompress(<<header_bytes::size(@header_length), rest::binary>>) do
    header_bit_len = header_bytes * @bits_per_byte
    <<header::size(header_bit_len), body::binary>> = rest

    char_counts = Header.from_binary(<<header::size(header_bit_len)>>)

    root =
      char_counts
      |> PriorityQueue.from_map()
      |> Tree.from_priority_queue()

    decompressed_output(body, root, root, [])
  end

   defp decompressed_output(_rest, _root, %{left: nil, right: nil, character: <<255>>}, iolist) do
     iolist
   end

  defp decompressed_output(rest, root, %{left: nil, right: nil} = node, iolist) do
    decompressed_output(rest, root, root, [iolist, node.character])
  end

  defp decompressed_output(<<1::size(1), rest::bitstring>>, root, node, iolist) do
    decompressed_output(rest, root, node.right, iolist)
  end

  defp decompressed_output(<<0::size(1), rest::bitstring>>, root, node, iolist) do
    decompressed_output(rest, root, node.left, iolist)
  end
end
