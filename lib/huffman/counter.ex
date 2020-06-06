defmodule Huffman.Counter do
  @moduledoc false

  @doc """
  Counts the number of unique characters in a file and returns the count in a map in the format %{char => count}.

  ## Examples
    iex> Huffman.Counter.count(["go", " ", "go", " ", "gophers"])
    %{" " => 2, "e" => 1, "g" => 3, "h" => 1, "o" => 3, "p" => 1, "r" => 1, "s" => 1}

    iex> Huffman.Counter.count([])
    %{}
  """
  @spec count(list(binary) | %File.Stream{}, keyword()) :: map()
  def count([], _opts), do: %{}

  def count(input, opts) do
    with_flow? = Keyword.get(opts, :flow?, false)

    if with_flow? do
      count_flow(input)
    else
      count_stream(input)
    end
  end

  def count_stream(binaries) do
    binaries
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Stream.map(&count_helper(&1, %{}))
    |> Enum.reduce(&merge_maps(&1, &2))
  end

  def count_flow(stream) do
    Flow.from_enumerable(stream)
    |> Flow.flat_map(&String.split(&1, "", trim: true))
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      Map.update(acc, word, 1, &(&1 + 1))
    end)
    |> Enum.into(%{})
  end

  @spec count_helper(list(binary) | list(), map()) :: map()
  defp count_helper([], acc), do: acc

  defp count_helper([head | tail], acc) do
    acc = Map.update(acc, head, 1, &(&1 + 1))
    count_helper(tail, acc)
  end

  @spec merge_maps(map(), map()) :: map()
  defp merge_maps(x, y), do: Map.merge(x, y, fn _k, v1, v2 -> v2 + v1 end)
end
