defmodule Huffman.TreeNodeTest do
  use ExUnit.Case, async: true
  alias Huffman.TreeNode
  doctest Huffman.TreeNode
  @moduledoc false

  test "converts from tuple" do
    result = Huffman.TreeNode.from_tuple({"a", 3})
    expected = %Huffman.TreeNode{character: "a", weight: 3}
    assert expected == result
  end

  test "merge two leaf nodes" do
    left_child = %TreeNode{character: "a", weight: 3}
    right_child = %TreeNode{character: "b", weight: 6}

    result = Huffman.TreeNode.merge(left_child, right_child)
    expected = %TreeNode{
      character: nil,
      weight: 9,
      left: left_child,
      right: right_child
    }

    assert expected == result
  end

  test "merge leaf node into non-leaf node" do
    left_child = %TreeNode{character: "a", weight: 3}
    right_child = %TreeNode{character: "b", weight: 6}
    parent = Huffman.TreeNode.merge(left_child, right_child)

    right_child = %TreeNode{character: "c", weight: 10}
    result = Huffman.TreeNode.merge(parent, right_child)

    expected = %TreeNode{
      character: nil,
      weight: 19,
      left: parent,
      right: right_child
    }

    assert expected == result
  end
end
