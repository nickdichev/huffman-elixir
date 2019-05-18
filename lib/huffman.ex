defmodule Huffman do
  alias Huffman.{Counter, Header, IOHelper, PriorityQueue, Tree}
  @moduledoc false

  @header_length 32

  @doc """
  Compresses an input file. The output file is the original filename with ".hf" appended.
  """
  @spec compress_file(binary()) :: :ok
  def compress_file(filename) do
    compressed_data =
      filename
      |> File.stream!()
      |> compress()

    File.write!(filename <> ".hf", compressed_data)
  end

  @doc """
  Compresses an input binary. An iolist of the compressed output is returned.
  """
  @spec compress(binary() | iolist() | %File.Stream{}) :: list(binary())
  def compress(bin) when is_binary(bin), do: compress([bin])

  @doc """
  Compresses an input iolist. An iolist of the compressed output is returned.
  """
  def compress(input) do
    # Get the character counts for the input. Used to write the header and to build the tree
    # We also need to add the EOF to the char counts so we can get an encoding for it, to be stored
    # in the header
    char_counts =
      input
      |> Counter.count()
      |> Map.put(<<255>>, 1)

    # Generate the Huffman header that will be used for decompression
    header_task = Task.async(Header, :get_header, [char_counts])

    # Generate the Huffman encodings from the character counts
    encodings = get_encodings(char_counts)

    {header, header_num_bytes} = Task.await(header_task)

    # Generate the compressed output from the encodings/input data
    {body, buffer} =
      encodings
      |> compressed_output(input)
      |> Enum.to_list()
      |> IOHelper.buffer_output(<<>>, [])

    # There might be something leftover in the buffer, lets grab that bitstring,
    # append the EOF, and pad if neccessary
    eof_encoding = Map.get(encodings, <<255>>)
    eof = IOHelper.pad_bitstring(<<buffer::bitstring, eof_encoding::bitstring>>)

    [<<header_num_bytes::size(@header_length)>>, header, body, eof]
  end

  defp get_encodings(char_counts) do
      char_counts
      |> PriorityQueue.from_map()
      |> Tree.from_priority_queue()
      |> Tree.inorder()
  end

  # Convert some input into its Huffman encoded representation line-by-line
  defp compressed_output(encodings, input) do
    input
    |> Stream.map(&String.split(&1, ""))
    |> Stream.map(&Enum.filter(&1, fn x -> x != "" end))
    |> Stream.map(&IOHelper.encode_characters(&1, encodings))
    |> Stream.flat_map(&List.flatten/1)
  end

  @doc """
  Decompresses an input file that should have been compressed by this program. The output file
  name is the input filename with ".orig" appended.
  """
  @spec decompress_file(binary()) :: :ok
  def decompress_file(filename) do
    decompressed_data =
      filename
      |> File.read!()
      |> decompress()

    File.write!(filename <> ".orig", decompressed_data)
  end

  @doc """
  Decompresses an input iolist. An iolist of the decompressed output is returned.
  """
  @spec decompress(list(binary())) :: iolist()
  def decompress([header_bytes, header, iodata, eof] = iolist) when is_list(iolist) do
    body_binary = IO.iodata_to_binary(iodata)
    decompress(header_bytes <> header <> body_binary <> eof)
  end

  @doc """
  Decompresses an input binary. An iolist of the decompressed output is returned.
  """
  @spec decompress(binary()) :: iolist()
  def decompress(<<header_bytes::size(@header_length), rest::binary>>) do
    <<header::bytes-size(header_bytes), body::binary>> = rest

    char_counts = Header.from_binary(header)

    root =
      char_counts
      |> PriorityQueue.from_map()
      |> Tree.from_priority_queue()

    decompressed_output(body, root, root, [])
  end

  # Final base case of decompression, at a leaf node that is the EOF character.
   defp decompressed_output(_rest, _root, %{left: nil, right: nil, character: <<255>>}, iolist) do
     iolist
   end

   # Append the character of the current leaf node to the iolist.
  defp decompressed_output(rest, root, %{left: nil, right: nil} = node, iolist) do
    decompressed_output(rest, root, root, [iolist, node.character])
  end

  # Consume a 1 off the compressed encoding and go right for the next recursion
  defp decompressed_output(<<1::size(1), rest::bitstring>>, root, node, iolist) do
    decompressed_output(rest, root, node.right, iolist)
  end

  # Consume a 0 off the compressed encoding and go left for the next recursion
  defp decompressed_output(<<0::size(1), rest::bitstring>>, root, node, iolist) do
    decompressed_output(rest, root, node.left, iolist)
  end
end
