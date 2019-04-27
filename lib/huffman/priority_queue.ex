defmodule Huffman.PriorityQueue do
  alias Huffman.TreeNode
  @moduledoc false

  @type priority_queue :: list(queue_elem())
  @type queue_elem :: %Huffman.TreeNode{}

  # Private function to sort a priority queue. This function is called when we initially
  # build the queue, and when elements are inserted. The function is private since we
  # should _always_ return a queue sorted by weight to the caller.
  defp sort([]), do: []
  defp sort(queue), do: Enum.sort(queue, &sort(&1, &2))
  defp sort({_, weight_left}, {_, weight_right}), do: weight_left <= weight_right
  defp sort(%{weight: weight_left}, %{weight: weight_right}), do: weight_left <= weight_right

  @doc """
  Creates a priority queue from a map input. The queue is sorted in order of increasing weight.

  ## Examples
    iex> Huffman.PriorityQueue.from_map(%{"a" => 4, "b" => 1, "c" => 0})
    [
      %Huffman.TreeNode{character: "c", left: nil, right: nil, weight: 0},
      %Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 1},
      %Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4}
    ]

    iex> Huffman.PriorityQueue.from_map(%{})
    []
  """
  @spec from_map(map()) :: priority_queue()
  def from_map(char_counts) when is_map(char_counts) do
    char_counts
    |> Enum.into([])
    |> sort()
    |> Enum.map(&TreeNode.from_tuple(&1))
  end

  @doc """
  Pops an element from the "front" of the priority queue.

  ## Examples
    iex> Huffman.PriorityQueue.pop([
    ...>   %Huffman.TreeNode{character: "c", weight: 0},
    ...>   %Huffman.TreeNode{character: "b", weight: 1},
    ...> ])
    {%Huffman.TreeNode{character: "c", weight: 0}, [%Huffman.TreeNode{character: "b", weight: 1}]}

    iex> Huffman.PriorityQueue.pop([])
    {}
  """
  @spec pop(priority_queue()) :: {queue_elem(), priority_queue()} | {}
  def pop([]), do: {}
  def pop([head | tail]), do: {head, tail}

  @doc """
  Inserts an element onto the priority queue.

  ## Examples
    iex> Huffman.PriorityQueue.insert(
    ...>   [%Huffman.TreeNode{character: "c", weight: 5}],
    ...>   %Huffman.TreeNode{character: "b", weight: 0})
    [%Huffman.TreeNode{character: "b", weight: 0}, %Huffman.TreeNode{character: "c", weight: 5}]

    iex> Huffman.PriorityQueue.insert([], %Huffman.TreeNode{character: "a", weight: 5})
    [%Huffman.TreeNode{character: "a", weight: 5}]

  """
  @spec insert(priority_queue(), queue_elem()) :: priority_queue()
  def insert(queue, elem), do: [elem | queue] |> sort()
end
