defmodule Huffman.Counter do
  @moduledoc false

  @spec merge_maps(map(), map()) :: map()
  defp merge_maps(x, y), do: Map.merge(x, y, fn _k, v1, v2 -> v2 + v1 end)

  @doc """
  Counts the number of unique characters in a file and returns the count in a map in the format %{char => count}.

  ## Examples
    iex> Huffman.Counter.count(["go", " ", "go", " ", "gophers"])
    %{" " => 2, "e" => 1, "g" => 3, "h" => 1, "o" => 3, "p" => 1, "r" => 1, "s" => 1}

    iex> Huffman.Counter.count([])
    %{}
  """
  @spec count(list(binary) | %File.Stream{}) :: map()
  def count([]), do: %{}

  def count(binaries) do
    binaries
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Stream.map(&count_helper(&1, %{}))
    |> Enum.reduce(&merge_maps(&1, &2))
  end

  @spec count_helper(list(binary) | list(), map()) :: map()
  defp count_helper([], acc), do: acc

  defp count_helper([head | tail], acc) do
    acc = Map.update(acc, head, 1, &(&1 + 1))
    count_helper(tail, acc)
  end

end
