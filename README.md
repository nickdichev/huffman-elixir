# huffman-elixir

This repository contains an implementation of the Huffman algorithm in Elixir.

A blog post series describing the implementation of the algorithm can be found on my blog:

[Part 1 (Data Structures)](https://nickdichev.com/blog/2019/05/04/huffman-elixir-part1)

## Usage

You can run the program in an `iex` shell:

```bash
iex -S mix
```

Once you are in an `iex` shell, you can interact with the program as follows:

```elixir
iex(1)> gophers = Huffman.compress("go go gophers")
[
  <<0, 0, 0, 53>>,
  <<131, 80, 0, 0, 0, 77, 120, 218, 43, 97, 96, 96, 224, 204, 5, 18, 140, 10,
    137, 76, 96, 58, 53, 145, 17, 76, 167, 39, 50, 131, 233, 12, 40, 63, 31,
    202, 47, 128, 242, 139, 160, 116, 49, 148, 254, 159, 200, 8, ...>>,
  [[[[[], 26], 52], 122], 99],
  <<243, 64>>
]

iex(2)> Huffman.decompress(gophers)
[
  [
    [
      [[[[[[[[[[[], "g"], "o"], " "], "g"], "o"], " "], "g"], "o"], "p"], "h"],
      "e"
    ],
    "r"
  ],
  "s"
]
```

There are also some sample text files included in `test_data/`. They can be compressed/decompressed as follows:

```elixir
iex(1)> Huffman.compress_file("test_data/hamlet")
:ok
iex(2)> Huffman.decompress_file("test_data/hamlet.hf")
:ok
```

Let's compare the file sizes of the original and compressed files:

```bash
ls -lh test_data/hamlet*
-rw-r--r--  1 ndichev  688605420   175K May  1 23:04 test_data/hamlet
-rw-r--r--  1 ndichev  688605420   102K May  4 16:29 test_data/hamlet.hf
-rw-r--r--  1 ndichev  688605420   175K May  4 16:29 test_data/hamlet.hf.orig


diff test_data/hamlet test_data/hamlet.hf.orig
<no  output>
```

## Testing

There are some unit tests in `tests/`. The unit test suite can be run with `mix test`. Additionally, `excoveralls` is configured and can be run with `mix coveralls` or `mix coveralls.html`.