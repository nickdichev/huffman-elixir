defmodule Huffman.TreeTest do
  use ExUnit.Case, async: true
  alias Huffman.{Tree, TreeNode}
  @moduledoc false

  setup do
    queue = [
      %TreeNode{character: "b", left: nil, right: nil, weight: 1},
      %TreeNode{character: "c", left: nil, right: nil, weight: 1},
      %TreeNode{character: "a", left: nil, right: nil, weight: 4},
      %TreeNode{character: "d", left: nil, right: nil, weight: 10}
    ]
    {:ok, queue: queue}
  end

  test "creates tree from priority queue", %{queue: queue} do
    root = Tree.from_priority_queue(queue)

    expected = %TreeNode{
      character: nil,
      left: %TreeNode{
        character: nil,
        left: %TreeNode{
          character: nil,
          left: %TreeNode{character: "b", left: nil, right: nil, weight: 1},
          right: %TreeNode{character: "c", left: nil, right: nil, weight: 1},
          weight: 2
        },
        right: %TreeNode{character: "a", left: nil, right: nil, weight: 4},
        weight: 6
      },
      right: %TreeNode{character: "d", left: nil, right: nil, weight: 10},
      weight: 16
    }

    assert expected == root
  end

  test "gets encodings from a Huffman tree", %{queue: queue} do
    root = Tree.from_priority_queue(queue)
    encodings = Tree.inorder(root)
    expected = %{"a" => <<1::size(2)>>, "b" => <<0::size(3)>>, "c" => <<1::size(3)>>, "d" => <<1::size(1)>>}

    assert expected == encodings
  end

end
