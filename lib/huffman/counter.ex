defmodule Huffman.Counter do
  @moduledoc false

  @doc """
  Counts the number of unique words in a list and returns the count in a map in the format %{word => count}.

  ## Examples
    iex> Huffman.Counter.count_words(["apple", "toast", "apple"])
    %{"apple" => 2, "toast" => 1}
  """
  @spec list(binary) :: map()
  def count_words(word_list), do: count(word_list, %{})

  defp count([], acc), do: acc

  defp count([head | tail], acc) do
    acc = Map.update(acc, head, 1, &(&1 + 1))
    count(tail, acc)
  end

end
