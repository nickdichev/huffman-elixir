defmodule Huffman.TreeNode do
  use TypedStruct
  @moduledoc false

  typedstruct do
    field :character, iodata() | nil, default: nil
    field :weight, integer(), default: 0
    field :left, tuple() | nil, default: nil
    field :right, tuple() | nil, default: nil
  end

  @doc """
  Converts a {character, weight} tuple into a %Huffman.TreeNode{} struct.

  ## Examples
    iex> Huffman.TreeNode.from_tuple({"a", 3})
    %Huffman.TreeNode{character: "a", weight: 3}
  """
  def from_tuple({character, weight}) do
    %Huffman.TreeNode{
      character: character,
      weight: weight
    }
  end
end
