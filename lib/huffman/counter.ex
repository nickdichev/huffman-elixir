defmodule Huffman.Counter do
  alias __MODULE__

  @moduledoc false

  @spec merge_maps(map(), map()) :: map()
  defp merge_maps(x, y), do: Map.merge(x, y, fn _k, v1, v2 -> v2 + v1 end)

  @doc """
  Counts the number of unique words in a file and returns the count in a map in the format %{word => count}.
  """
  @spec count(binary()) :: map()
  def count(filename) when is_binary(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.split(&1, ~r"\b"))
    |> Stream.map(&Enum.filter(&1, fn x -> x != "" end))
    |> Stream.map(&Counter.count(&1))
    |> Enum.reduce(&merge_maps(&1, &2))
  end

  @doc """
  Counts the number of unique words in a list and returns the count in a map in the format %{word => count}.

  ## Examples
    iex> Huffman.Counter.count(["apple", "toast", "apple"])
    %{"apple" => 2, "toast" => 1}
  """
  @spec count([iodata()]) :: map()
  def count(words) when is_list(words), do: count(words, %{})

  @spec count([], map()) :: map()
  defp count([], acc), do: acc

  @spec count([iodata(), ...], map()) :: map()
  defp count([head | tail], acc) do
    acc = Map.update(acc, head, 1, &(&1 + 1))
    count(tail, acc)
  end

end
