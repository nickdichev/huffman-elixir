defmodule Huffman.TreeNode do
  use TypedStruct
  alias __MODULE__
  @moduledoc false

  @type tree_node() :: %Huffman.TreeNode{}

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
  @spec from_tuple(tuple()) :: tree_node()
  def from_tuple({character, weight}) do
    %TreeNode{
      character: character,
      weight: weight
    }
  end

  @doc """
  Merges two %Huffman.TreeNode{} into a singular parent %Huffman.TreeNode{}. The parent holds the children in `:left` and `:right`.

  ## Examples
    iex> left_child = %Huffman.TreeNode{character: "a", weight: 3}
    ...> right_child = %Huffman.TreeNode{character: "b", weight: 6}
    ...> Huffman.TreeNode.merge(left_child, right_child)
    %Huffman.TreeNode{character: nil, weight: 9, left: %Huffman.TreeNode{character: "a", weight: 3}, right: %Huffman.TreeNode{character: "b", weight: 6}}
  """
  @spec merge(tree_node(), tree_node()) :: tree_node()
  def merge(left_child, right_child) do
    weight = left_child.weight + right_child.weight
    %TreeNode{weight: weight, left: left_child, right: right_child}
  end
end
