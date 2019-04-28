defmodule Huffman.Tree do
  alias Huffman.{PriorityQueue, TreeNode}
  @moduledoc false

  @type priority_queue :: list(tree_node())
  @type tree_node :: %Huffman.TreeNode{}

  @doc """
  Flattens a Huffman priority queue into a single %Huffman.TreeNode{}.
  """
  @spec from_priority_queue(priority_queue()) :: tree_node()
  def from_priority_queue(queue), do: flatten(queue)

  # Base of the recursion, there is only one node left -- the root of the Huffman tree
  defp flatten([root | []]), do: root

  defp flatten(queue) do
    # Pop the two lowest weight nodes off of the queue
    {left_child, queue} = PriorityQueue.pop(queue)
    {right_child, queue} = PriorityQueue.pop(queue)

    # Merge the two nodes into a new node, and put the new node on the queue
    parent = TreeNode.merge(left_child, right_child)
    queue = PriorityQueue.insert(queue, parent)

    # Keep the recursion going
    flatten(queue)
  end

  @doc """
  Complete a recursive inorder traversal of the Huffman tree. While the recursion is happening
  the "path" of the recursion is tracked. 0 represents going left in the tree, while 1
  represents going right in the tree. When the recursion hits the base case, a leaf node, the
  recursion path is stored for the character that leaf node represents.
  """
  @spec inorder(tree_node()) :: map()
  def inorder(root) do
    # Start an agent which stores the final encoding for each leaf node
    # We are only doing simple inserts, so lets not worry about supervision
    {:ok, agent} = Agent.start(fn -> %{} end)

    # Actually do the recursion, passing in the agent to keep track of state
    inorder(root, [], agent)

    # Get the final state of the map
    encoding_map = Agent.get(agent, fn state -> state end)

    # Cleanup then return the map to the caller
    Agent.stop(agent)
    encoding_map
  end

  # Base of the recursion, we are at a leaf node when :left and :right are nil
  defp inorder(%{left: nil, right: nil} = node, iolist, agent) do
    Agent.update(agent, &Map.put(&1, node.character, iolist))
  end

  defp inorder(node, iolist, agent) do
    inorder(node.left, [iolist, <<0 :: size(1)>>], agent)
    inorder(node.right, [iolist, <<1 :: size(1)>>], agent)
  end

end
