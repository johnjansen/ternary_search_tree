# Ternary Search Tree - (pure crystal-lang)

[![GitHub version](https://badge.fury.io/gh/johnjansen%2Fternary_search_tree.svg)](http://badge.fury.io/gh/johnjansen%2Fternary_search_tree)
[![CI](https://travis-ci.org/johnjansen/ternary_search_tree.svg?branch=master)](https://travis-ci.org/johnjansen/ternary_search_tree)

In computer science, a ternary search tree is a type of trie (sometimes called a prefix tree) where nodes are arranged in a manner similar to a binary search tree, but with up to three children rather than the binary tree's limit of two. Like other prefix trees, a ternary search tree can be used as an associative map structure with the ability for incremental string search. However, ternary search trees are more space efficient compared to standard prefix trees, at the cost of speed. Common applications for ternary search trees include spell-checking and auto-completion. (wikipedia)

Furthur considerations from (Hackthology)[http://hackthology.com/ternary-search-tries-for-fast-flexible-string-search-part-1.html]

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  ternary_search:
    github: johnjansen/ternary_search
```

## Usage

```crystal
require "ternary_search"

tst = TernarySearch::Tree.new

# add to the TST
tst.insert("polygon")  # => nil
tst.insert("triangle") # => nil

# search the TST
tst.search("polygon")  # => true
tst.search("poly")     # => false
tst.search("triangle") # => true

# get the max word length
tst.max_word_length # => 8

# get an array of words in the TST
# DO NOT USE THIS ON LARGE TST's
# i'm looking into a block version of this!
tst.words = ["polygon", "triangle"]
```

## Contributing

1. Fork it ( https://github.com/johnjansen/ternary_search/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [johnjansen](https://github.com/johnjansen) John Jansen - creator, maintainer
- [RX14](https://github.com/RX14) Chris Hobbs - rewriter, maintainer
