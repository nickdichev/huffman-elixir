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

However, Huffman realized he could do better. Notice that the characters 'g', 'o', and ' ' occur more frequently than the rest of the characters in our example string. Huffman's algorithim creates a more efficient encoding by assigning smaller (less bits) encodings to characters which occur more frequently. Let's take a look at the data structures we will need to create to implement Huffman's algorithim.

## Data Structures