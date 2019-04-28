defmodule Huffman do
  alias Huffman.{Counter, IOHelper, PriorityQueue, Tree}
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

    # Generate the Huffman header that will be used for decompression
    {header, header_len} = Header.get_header(char_counts)

    # Generate the compressed "body"
    body =
      char_counts
      |> PriorityQueue.from_map()
      |> Tree.from_priority_queue()
      |> Tree.inorder()
      |> compressed_output(iolist)
      |> Stream.flat_map(&List.flatten/1)
      |> Enum.to_list()
      |> IOHelper.buffer_output(<<>>, [])

    # Write the header length in the first 32 bits, then the header, then the compressed body
    [<<header_len::size(32)>>, header, body]
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
end
