defmodule Huffman.CounterTest do
  use ExUnit.Case, async: true
  alias Huffman.Counter
  doctest Huffman.Counter

  @moduledoc false

  test "counts basic list" do
    result = Counter.count(["go", " ", "go", " ", "gophers"])
    expected = %{" " => 2, "e" => 1, "g" => 3, "h" => 1, "o" => 3, "p" => 1, "r" => 1, "s" => 1}
    assert expected == result
  end

  test "counts empty list" do
    result = Counter.count([])
    assert %{} == result
  end

  test "counts zany characters" do
    result = Counter.count(["⚡", "🦒", "\r\n", "⚡", "apple"])
    expected = %{"\r\n" => 1, "⚡" => 2, "🦒" => 1, "a" => 1, "p" => 2, "l" => 1, "e" => 1}
    assert expected == result
  end
end
