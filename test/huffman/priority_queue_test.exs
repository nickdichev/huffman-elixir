defmodule Huffman.PriorityQueueTest do
  use ExUnit.Case, async: true
  alias Huffman.PriorityQueue
  doctest Huffman.PriorityQueue
  @moduledoc false

  test "creates queue from populated map" do
    result = PriorityQueue.from_map(%{"a" => 4, "b" => 1, "c" => 0})
    assert [{"c", 0}, {"b", 1}, {"a", 4}] == result
  end

  test "creates queue from empty map" do
    result = PriorityQueue.from_map(%{})
    assert [] == result
  end

  test "pops off populated queue" do
    result = PriorityQueue.pop([{"c", 0}, {"a", 3}, {"b", 5}])
    assert {{"c", 0}, [{"a", 3}, {"b", 5}]} = result
  end

  test "pops off empty queue" do
    result = PriorityQueue.pop([])
    assert {} == result
  end

  test "insert element into a queue" do
    result = Huffman.PriorityQueue.insert([{"a", 3}], {"b", 0})
    assert [{"b", 0}, {"a", 3}] == result
  end

  test "insert element into empty queue" do
    result = Huffman.PriorityQueue.insert([], {"b", 0})
    assert [{"b", 0}] == result
  end
end
