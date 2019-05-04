defmodule Huffman.PriorityQueueTest do
  use ExUnit.Case, async: true
  alias Huffman.PriorityQueue
  doctest Huffman.PriorityQueue
  @moduledoc false

  test "creates queue from populated map" do
    result = PriorityQueue.from_map(%{"a" => 4, "b" => 1, "c" => 0})

    expected = [
      %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0},
      %Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 1},
      %Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4}
    ]

    assert expected == result
  end

  test "creates queue from empty map" do
    result = PriorityQueue.from_map(%{})
    assert [] == result
  end

  test "pops off populated queue" do
    result = PriorityQueue.pop([
      %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0},
      %Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 1},
      %Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4}
    ])

    expected = {
      %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0},
      [
        %Huffman.TreeNode{
          character: "b",
          left: nil,
          right: nil,
          weight: 1
        },
        %Huffman.TreeNode{
          character: "a",
          left: nil,
          right: nil,
          weight: 4
        }
    ]}

    assert expected == result
  end

  test "pops off empty queue" do
    result = PriorityQueue.pop([])
    assert nil == result
  end

  test "insert element into a queue" do
    initial_queue = [%Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0}]
    new_elem = %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0}

    result = Huffman.PriorityQueue.insert(initial_queue, new_elem)

    expected = [
      %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0},
      %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0}
    ]

    assert expected == result
  end

  test "insert element into empty queue" do
    new_elem = %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0}
    result = Huffman.PriorityQueue.insert([], new_elem)
    expected = [%Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0}]
    assert expected == result
  end
end
