# Compressing Files With Elixir

## Implementing the Huffman algorithim: data structures

The Erlang and Elixir communities recently lost an important member of the community, Joe Armstrong. In his talk "The mess we've gotten ourselves into", Joe mentions a system he had thought of to compress all known programs; to essentially delete all duplicate programs. This reminded me of a compression program I have previously written, a Java implementation of the Huffman algorithim.

This post is the first in a series which will be exploring powerful, although seemingly basic, features of the Elixir programming language which make implementing the Huffman algorithim a breeze. Some of features we will look into are: binary pattern matching, iolists, and recursion.

This post will serve as an introduction to the Huffman algorithim and the data structures we will be using to implement the the algorithim.

## Introduction

David Huffman, who founded the computer science department at my alma mater UC Santa Cruz (go bannana slugs!), invented the Huffman algorithim in 1951 while he was a student at MIT. Huffman was tasked with an assignment to generate efficient binary encodings. Huffman realized he could generate these encodings with a frequency sorted binary tree and actually created a better algorithim than the professor who gave the assignment!

Efficient binary encodings? Frequency sorted binary tree? What are these things? Thankfully, we don't need a degree from MIT to understand these concepts.

First, we need a basic understanding of how text is stored in files. Computers can only store binary data, however, binary data is unreadable to (most) people. Fortunately for us, characters such as 'x', '1', or '\n' can be encoded as binary data in a variety of ways. One such encoding, ASCII, stores characters as binary data in either seven or eight bits. With seven bits we can store the values 0 - 127. This gives us 128 possible characters we can encode with ASCII. With eight bits we can store 0 - 255 for 256 possible characters. For the following examples, assume we're using seven bits.

For example, the character 'x' in ASCII is represented by the decimal value 120 or binary `1111000`. You can find [ASCII tables](https://www.ascii-code.com/) online for more examples. Consider the string "go go gophers". This string can be encoded as:

```bash
1100111 1101111 1100000 1100111 1101111 1000000 1100111 1101111 1110000 1101000 1100101 1110010 1110011
```

However, the string "go go gophers" only has 8 unique characters: 'g', 'o', ' ', 'p', 'h', 'e', 'r', and 's'. This means we can create an encoding using only three bits. We can create a lookup table for our encoding:

```bash
'g' => 000
'o' => 001
' ' => 010
'p' => 011
'h' => 100
'e' => 101
'r' => 110
's' => 111
```

With our lookup table we can encode "go go gophers" as:

```bash
000 001 010 000 001 010 000 001 011 100 101 110 111
```

With ASCII we need 56 bits to store the string, however, with our encoding we only need 24! Thats about a 42 percent reduction in size. These are the "efficient binary encodings" Huffman was looking for!

However, Huffman realized he could do better. Notice that the characters 'g', 'o', and ' ' occur more frequently than the rest of the characters in our example string. Huffman's algorithim creates more efficient encoding by assigning smaller (less bits) encodings to characters which occur more frequently. Let's take a look at the data structures we will need to implement Huffman's algorithim.

## Data Structures -- Explanation

If you are already familiar with binary trees and priority queues feel free to skip to the next section.

There are two data structures that we need to implement: a binary tree and a priority queue. I will not cover the intricacies of these data structures. There are plenty of resources online if you are unfamiliar or need a refresher on the details of these data structures. However, let's take a look at the basics.

### Binary Tree

A binary tree node is a singular element which can contain some data and pointers to up to two "children" elements. A node's children can have its own children. A collection of binary tree nodes form a binary tree. However, a binary tree is typically only represented by a singular tree node -- the "root" of the binary tree. The entire binary tree can be iterated over by looking at the children of the root node, the children of those nodes, and so on. Tree nodes with no children are called leaf nodes.

```bash
                +---------------------------+
                |         Data: "a"         |
                |                           |   < Root
                |Left Child      Right Child|
                +-+----------------------+--+
                  |                      |
                  |                      |
   +--------------+----------+       +---+---------------------+
   |        Data:  "b"       |       |        Data: "c"        |
   |                         |       |                         |   < Leaf node
   |Left Child    Right Child|       |Left Child    Right child|
   +---+----------------+----+       +----+----------------+---+
       |                |                 |                |
+------+------+   +-----+------+   +------+-----+    +-----+------+
|    nil      |   |    nil     |   |     nil    |    |    nil     |
+-------------+   +------------+   +------------+    +------------+

```

### Priority Queue

A priority queue is similar to a queue, however, the queue is sorted by priority. Consider the following queue operations:

```elixir
[] :: initial queue
[{priority: 3}] :: insert with priority 3
[{priority: 3}, {priority: 1}] :: insert with priority 1
{priority: 3}, [{priority: 1}] :: dequeue
```

Since a queue is a first-in-first-out data structure, elements are removed in the order which they were placed in the queue. Since we inserted the element with priorty 3 before the element with priorty 1, it came off the queue first. Consider the same operations on a priority queue (assuming 1 is a higher priority value than 3):

```elixir
[] :: initial queue
[{priority: 3}] :: insert with priority 3
[{priority: 1}, {priority: 3}] :: insert with priority 1
{priority: 1}, [{priority: 1}] :: dequeue
```

Notice that in the priority queue elements are placed into the queue depending on their priority. This also means that elements are removed from the queue in order of priority.

Now that we have an understanding of the data structures, lets take a look at how we can implement them in Elixir.

## Data Structures -- Implementation

### Tree Node Implementation

Let' start by creating a new mix project, and creating a file for our implementation of the binary tree node.

```bash
mix new huffman
touch lib/huffman/TreeNode.ex
```

We will be using a struct to represent the tree nodes. In Elixir a struct is similar to a map, however, it has tagged keys. For our tree node we want to store: a character, a weight (the character's frequency), and the left and right children. Let's take a quick look at the interfaces for the functions we will need to implement:

```bash
from_tuple/1 : create a TreeNode from  a {character, weight} tuple

merge/2 : merge two TreeNodes into a new parent TreeNode
```

Let's open `TreeNode.ex` and complete the implementation of the struct and functions.

```elixir
defmodule Huffman.TreeNode do
  defstruct [:character, :left, :right, weight: 0]
  alias __MODULE__

  def from_tuple({character, weight}) do
    %TreeNode{
      character: character,
      weight: weight
    }
  end

  def merge(left_child, right_child) do
    weight = left_child.weight + right_child.weight
    %TreeNode{weight: weight, left: left_child, right: right_child}
  end

end
```

In our implementation only leaf nodes will store a character. When nodes are merged, we will store the sum of the child node's weights in the new parent node. We will see why we must do this in the priority queue implementation.

Let's open an `iex` shell and test our code:

```elixir
iex(1)> %Huffman.TreeNode{}
%Huffman.TreeNode{character: nil, left: nil, right: nil, weight: 0}

iex(2)> left_child = Huffman.TreeNode.from_tuple({"a", 4})
%Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4}

iex(3)> right_child = Huffman.TreeNode.from_tuple({"b", 2})
%Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 2}

iex(4)> Huffman.TreeNode.merge(left_child, right_child)
%Huffman.TreeNode{
  character: nil,
  left: %Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4},
  right: %Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 2},
  weight: 6
}
```

## Priority Queue Implementation

We will use a list as the backbone of our priority queue implementation. Our implementation will queue TreeNode structs in order of increasing character weight. That is to say, a character with frequency 1 will come before a character with frequency 3 in the priority queue. Let's look at the interfaces for the functions we need to implement:

```bash
from_map/1 : convert a %{character => weight, ...} map to a priority queue

pop/1 : pop the lowest weight element off of the priority queue

insert/2 : insert a TreeNode into the priority queue
```

Let's create the file `lib/huffman/priority_queue.ex` and start with our implementation of `pop/1`.

```elixir
defmodule Huffman.PriorityQueue do
  def pop([]), do: nil
  def pop([head | tail]), do: {head, tail}
end
```

We have two versions of `pop/1`. The `pop([])` function will be called if an empty priority queue is passed into `pop/1`. In this case, there is nothing to pop off of the queue, so we simply return `nil`. The second case, `pop([head | tail])` will execute when `pop/1` is called with a non-empty list. The `head` variable will match an element on the front of the queue and `tail` variable will match the remainder of the list. We return the `head` and `tail` in a tuple.

Now, let's look at the implementation of `insert/2`. This function will take a priority queue and a TreeNode as parameters. The function will insert the new element onto the front of the queue then sort the queue to maintain the priority ordering of the elements.

```elixir
defmodule Huffman.PriorityQueue do
  ...
  def insert(queue, elem), do: [elem | queue] |> sort()

  defp sort([]), do: []
  defp sort(queue), do: Enum.sort(queue, &sort/2)
  defp sort(%{weight: weight_left}, %{weight: weight_right}), do: weight_left <= weight_right
end
```

Let's dive into what's happening when we sort the priority queue. If an empty queue is passed in we have no work to do, simply return an empty list. If a non-empty queue is passed in, we use `Enum.sort/2` to sort the queue with a given sort function. Our actual sort function `sort/2`, given two `TreeNode`, will pattern match on the `:weight` key of each element, and compare them.

The final function we need to implement is `from_map/1`. This function will take in a `%{character => count}` map and return a priority queue.

```elixir
defmodule Huffman.PriorityQueue do
  alias Huffman.TreeNode
  ...
  def from_map(char_counts) when is_map(char_counts) do
    char_counts
    |> Enum.into([])
    |> Enum.map(&TreeNode.from_tuple(&1))
    |> sort()
  end
end
```

The function takes the map, uses `Enum.into/2` to convert the map into a list of tuples. Each tuple will have the form of `{character, weight}`. The list of tuples is then passed into `Enum.map/2` which will convert each tuple with `Huffman.TreeNode.from_tuple/1`. At this point, we have a list of `TreeNode`, however, they are not sorted. We pass the unsorted queue into `sort/1` which will return a priority queue.

Let's see some examples of the code we just implemented:

```elixir
iex(1)> queue = Huffman.PriorityQueue.from_map(%{"a" => 4, "b" => 1})
[
  %Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 1},
  %Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4}
]

iex(2)> Huffman.PriorityQueue.pop(queue)
{%Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 1},
 [%Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4}]}

iex(3)> new_node = Huffman.TreeNode.from_tuple({"d", 2})
%Huffman.TreeNode{character: "d", left: nil, right: nil, weight: 2}

iex(4)> Huffman.PriorityQueue.insert(queue, new_node)
[
  %Huffman.TreeNode{character: "b", left: nil, right: nil, weight: 1},
  %Huffman.TreeNode{character: "d", left: nil, right: nil, weight: 2},
  %Huffman.TreeNode{character: "a", left: nil, right: nil, weight: 4}
]
```