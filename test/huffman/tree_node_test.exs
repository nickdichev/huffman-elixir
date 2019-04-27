defmodule Huffman.TreeNodeTest do
  use ExUnit.Case, async: true
  doctest Huffman.TreeNode
  @moduledoc false

  test "converts from tuple" do
    result = Huffman.TreeNode.from_tuple({"a", 3})
    expected = %Huffman.TreeNode{character: "a", weight: 3}
    assert expected == result
  end
end
