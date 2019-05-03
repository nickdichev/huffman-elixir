defmodule Huffman.IOHelperTest do
  use ExUnit.Case, async: true
  alias Huffman.IOHelper

  test "buffers output into a binary and leftover buffer" do
    bitstrings = [<<1::size(2), 3::size(3)>>]

    result = IOHelper.buffer_output(bitstrings, <<2::size(6)>>, [])
    expected = {[[], 9], <<3::size(3)>>}
    assert expected == result
  end

  test "buffer output base case" do
    assert {["a"], <<3::size(2)>>} == IOHelper.buffer_output([], <<3::size(2)>>, ["a"])
  end

  test "completed_byte chomps a completed byte" do
    bitstring = <<6, 3::size(3)>>
    result = IOHelper.completed_byte(bitstring)
    assert {6, <<3::size(3)>>} == result
  end

  test "completed_byte bad result on bitstring" do
    bitstring = <<4::size(5), 1::size(2)>>
    result = IOHelper.completed_byte(bitstring)
    assert {nil, nil} = result
  end

  test "converts iolist with encodings" do
    encodings = %{
      "a" => <<1::size(2)>>,
      "b" => <<0::size(2)>>,
      "c" => <<3::size(3)>>
    }
    iolist = ["a", "b", "c", "b", "c"]
    result = IOHelper.encode_characters(iolist, encodings)
    expected = [<<1::size(2)>>, <<0::size(2)>>, <<3::size(3)>>, <<0::size(2)>>, <<3::size(3)>>]
    assert expected == result

    result = IOHelper.encode_characters(iolist, %{"b" => <<1::size(2)>>})
    assert [nil, <<1::size(2)>>, nil, <<1::size(2)>>, nil] == result
  end

  test "pad_bitstring doesn't pad binary" do
    assert <<4, 2>> == IOHelper.pad_bitstring(<<4, 2>>)
  end

  test "pad_bitstring pads to the nearest multiple of 8 bits" do
    assert <<3::size(4), 0::size(4)>> == IOHelper.pad_bitstring(<<3::size(4)>>)
    assert <<15::size(13), 0::size(3)>> == IOHelper.pad_bitstring(<<15::size(13)>>)
    assert <<1::size(17), 0::size(7)>> ==  IOHelper.pad_bitstring(<<1::size(17)>>)
    assert <<1::size(30), 0::size(2)>> == IOHelper.pad_bitstring(<<1::size(30)>>)
  end

end
