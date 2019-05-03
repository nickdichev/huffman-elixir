defmodule HuffmanTest do
  use ExUnit.Case, async: true
  alias Huffman.{Counter, Header}

  setup do
    char_counts =
      ["go go gophers"]
      |> Counter.count()
      |> Map.put(<<255>>, 1)
    {header, _} = Header.get_header(char_counts)

    compressed_binary = Huffman.compress("go go gophers")
    compressed_list = Huffman.compress(["go", " ", "go", " ", "gophers"])

    {:ok, cbin: compressed_binary, clist: compressed_list, header: header}
  end

  test "compresses basic input", %{cbin: cbin, clist: clist, header: header} do
    expected = [
      <<0, 0, 0, 53>>,
      header,
      [[[[[], 26], 52], 122], 99],
      <<243, 64>>
    ]
    assert expected == cbin
    assert expected == clist
  end

  test "decompressed basic input", %{cbin: cbin, clist: clist} do
    decompressed_bin =
      cbin
      |> Huffman.decompress()
      |> List.flatten()
      |> Enum.join()

    decompressed_list =
      clist
      |> Huffman.decompress()
      |> List.flatten()
      |> Enum.join()

    assert "go go gophers" == decompressed_bin
    assert "go go gophers" == decompressed_list
  end
end
