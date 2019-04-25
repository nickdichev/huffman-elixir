defmodule Huffman.CounterTest do
  use ExUnit.Case, async: true
  alias Huffman.Counter
  doctest Huffman.Counter

  @moduledoc false

  test "counts basic list" do
    result = Counter.count(["apple", "toast", "aardvark", "toast"])
    assert %{"apple" => 1, "toast" => 2, "aardvark" => 1} == result
  end

  test "counts empty list" do
    result = Counter.count([])
    assert %{} == result
  end

  test "counts zany characters" do
    result = Counter.count(["⚡", "🦒", "\r\n", "⚡", "apple"])
    assert %{"\r\n" => 1, "⚡" => 2, "🦒" => 1, "apple" => 1} == result
  end
end
