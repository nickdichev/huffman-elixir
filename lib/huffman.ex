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
    root =
      iolist
      |> get_huffman_tree()

    compressed_data =
      root
      |> Tree.inorder()
      |> compressed_output(iolist)
      |> Stream.flat_map(&List.flatten/1)
      |> Enum.to_list()
      |> buffer_output(<<>>, [])
  end

  # Format our list of improperly formatted binaries
  # iex(24)> quote(do: <<1::size(1)>> <> <<0::size(1)>>) |> Macro.expand(__ENV__) |> Macro.to_string()
  # "<<(<<1::size(1)>>::binary), (<<0::size(1)>>::binary)>>"
  # this doesn't work because we need to operate on bitstrings
  defp buffer_output([head | tail], buffer, iolist) do
    buffer = <<buffer::bitstring, head::bitstring>>
    iolist = if bit_size(buffer) == 8, do: [iolist, buffer], else: iolist
    buffer_output(tail, buffer, iolist)
  end

  defp buffer_output([], buffer, iolist) do
    # If we have anything left over in the buffer, we need to pad it
    buffer =
      if buffer != <<>> do
        pad_len = 8 - bit_size(buffer)
        padding = <<0::size(pad_len)>>
        <<buffer::bitstring, padding::bitstring>>
      else
        buffer
      end
      [iolist, buffer]
  end

  # Create a Huffman tree from some input
  defp get_huffman_tree(data_stream) do
    data_stream
    |> Counter.count()
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
