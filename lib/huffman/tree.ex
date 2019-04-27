defmodule Huffman.Tree do
  alias Huffman.{PriorityQueue, TreeNode}
  @moduledoc false

  @type priority_queue :: list(tree_node())
  @type tree_node :: %Huffman.TreeNode{}

  @spec from_priority_queue(priority_queue()) :: tree_node()
  def from_priority_queue(queue), do: flatten(queue)

  defp flatten([node | []]), do: node

  defp flatten(queue) do
    {left_child, queue} = PriorityQueue.pop(queue)
    {right_child, queue} = PriorityQueue.pop(queue)

    parent = TreeNode.merge(left_child, right_child)
    queue = PriorityQueue.insert(queue, parent)

    flatten(queue)
  end


end
