defmodule Huffman.PriorityQueue do
  @moduledoc false

  @type priority_queue :: list(queue_elem())
  @type queue_elem :: {iodata(), integer()}

  # Private function to sort a priority queue. This function is called when we initially
  # build the queue, and when elements are inserted. The function is private since we
  # should _always_ return a queue sorted by weight to the caller.
  @spec sort(priority_queue()) :: priority_queue()
  defp sort([]), do: []
  defp sort(queue), do: Enum.sort(queue, &sort(&1, &2))
  defp sort({_, x}, {_, y}), do: x <= y

  @doc """
  Creates a priority queue from a map input. The queue is sorted in order of increasing weight.

  ## Examples
    iex> Huffman.PriorityQueue.from_map(%{"a" => 4, "b" => 1, "c" => 0})
    [{"c", 0}, {"b", 1}, {"a", 4}]

    iex> Huffman.PriorityQueue.from_map(%{})
    []
  """
  @spec from_map(map()) :: priority_queue()
  def from_map(char_counts) when is_map(char_counts) do
    char_counts
    |> Enum.into([])
    |> sort()
  end

  @doc """
  Pops an element from the "front" of the priority queue.

  ## Examples
    iex> Huffman.PriorityQueue.pop([{"c", 0}, {"a", 3}, {"b", 5}])
    {{"c", 0}, [{"a", 3}, {"b", 5}]}

    iex> Huffman.PriorityQueue.pop([])
    {}
  """
  @spec pop(priority_queue()) :: {queue_elem(), priority_queue()} | {}
  def pop([]), do: {}
  def pop([head | tail]), do: {head, tail}

  @doc """
  Inserts an element onto the priority queue.

  ## Examples
    iex> Huffman.PriorityQueue.insert([{"a", 3}], {"b", 0})
    [{"b", 0}, {"a", 3}]

    iex> Huffman.PriorityQueue.insert([], {"a", 3})
    [{"a", 3}]
  """
  @spec insert(priority_queue(), queue_elem()) :: priority_queue()
  def insert(queue, elem), do: [elem | queue] |> sort()
end
