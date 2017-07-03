# A pure Crystal Ternary Search Tree

In computer science, a ternary search tree is a type of trie (sometimes called a prefix tree) where nodes are arranged in a manner similar to a binary search tree, but with up to three children rather than the binary tree's limit of two. Like other prefix trees, a ternary search tree can be used as an associative map structure with the ability for incremental string search. However, ternary search trees are more space efficient compared to standard prefix trees, at the cost of speed. Common applications for ternary search trees include spell-checking and auto-completion. (wikipedia)

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
tst.insert("polygon")  # => nil
tst.insert("triangle") # => nil
tst.search("polygon")  # => true
tst.search("poly")     # => false
tst.search("triangle") # => true
```

## Contributing

1. Fork it ( https://github.com/johnjansen/ternary_search/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [johnjansen](https://github.com/johnjansen) John Jansen - creator, maintainer
