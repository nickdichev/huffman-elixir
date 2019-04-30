defmodule Huffman do
  alias Huffman.{Counter, Header, IOHelper, PriorityQueue, Tree}
  @moduledoc false

  @header_length 32
  @bits_per_byte 8

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

    # Generate the Huffman header that will be used for decompression
    {header, header_num_bytes} = Header.get_header(char_counts)

    # Generate the compressed "body"
    body =
      char_counts
      |> PriorityQueue.from_map()
      |> Tree.from_priority_queue()
      |> Tree.inorder()
      |> compressed_output(iolist)
      |> Enum.to_list()
      |> IOHelper.buffer_output(<<>>, [])

    # Write the header length in the first 32 bits, then the header, then the compressed body
    [<<header_num_bytes::size(@header_length)>>, header, body]
  end

  # Convert some input into its Huffman encoded representation line-by-line
  defp compressed_output(encodings, iodata) do
    iodata
    |> Stream.map(&String.split(&1, ""))
    |> Stream.map(&Enum.filter(&1, fn x -> x != "" end))
    |> Stream.map(&IOHelper.encode_characters(&1, encodings))
    |> Stream.flat_map(&List.flatten/1)
  end

  def decompress_file(filename) do
    decompressed_data =
      filename
      |> File.read!()
      |> decompress()

    File.write!(filename <> ".orig", decompressed_data)
  end

  def decompress(<<header_bytes::size(32), rest::binary>> = iodata) do
    header_bit_len = header_bytes * @bits_per_byte
    <<header::size(header_bit_len), body::binary>> = rest

    char_counts = Header.from_binary(<<header::size(header_bit_len)>>)

    root =
      char_counts
      |> PriorityQueue.from_map()
      |> Tree.from_priority_queue()

    decompressed_output(body, root, root, [])
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

  def decompressed_output(<<>>, _root, _tree_node, iolist), do: iolist

end
