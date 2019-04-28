defmodule Huffman do
  alias Huffman.{Counter, PriorityQueue, Tree, IOHelper}
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
      |> IOHelper.buffer_output(<<>>, [])
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
end
