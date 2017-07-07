require "msgpack"
require "json"
require "yaml"

module TernarySearch
  # A Ternary Search Tree implementation
  # https://en.wikipedia.org/wiki/Ternary_search_tree
  #
  # ```
  # tst = TernarySearch::Tree.new
  # tst.insert("polygon")  # => nil
  # tst.insert("poly")     # => nil
  # tst.search("polygon")  # => true
  # tst.search("polygons") # => false
  # tst.search("poly")     # => true
  # tst.search("gon")      # => false
  # ```
  class Tree
    MessagePack.mapping({
      combined_value: UInt32,
      left:           Tree?,
      equal:          Tree?,
      right:          Tree?,
    })
    JSON.mapping({
      combined_value: UInt32,
      left:           Tree?,
      equal:          Tree?,
      right:          Tree?,
    })
    YAML.mapping({
      combined_value: UInt32,
      left:           Tree?,
      equal:          Tree?,
      right:          Tree?,
    })

    def initialize
    end

    # Contains the Char value of this tree node with the highest bit set if
    # the node represents the end of a word. This is done to reduce the size of
    # this class.
    @combined_value : UInt32 = 0_u32

    protected getter left : Tree?  # a tree where the next node value is less than this value
    protected getter equal : Tree? # a tree where the next node value is equal to this value
    protected getter right : Tree? # a tree where the next node value is greater than this value


    def value : Char?
      # Take the last 31 bits and convert to Char
      char = (@combined_value & ~(1 << 31)).chr

      # We use '\0' to signal a nil char value
      char == '\0' ? nil : char
    end

    private def value=(char : Char)
      # Take the value of this char as a UInt32
      value = char.ord.to_u32

      # Code points should never have the highest bit set
      # NUL is also invalid because we use it to signal nil
      raise "Invalid Char!" if value == 0 || value > (1 << 31) - 1

      # Set the highest bit if the word_end bit is set
      value |= 1 << 31 if word_end?

      @combined_value = value

      # Return the value we set
      char
    end

    def word_end? : Bool
      # Check the 32nd bit (index 31)
      @combined_value.bit(31) == 1
    end

    private def word_end=(word_end : Bool)
      if word_end
        # Set the 32nd bit
        @combined_value |= 1 << 31
      else
        # Unset the 32nd bit
        @combined_value &= ~(1 << 31)
      end

      word_end
    end

    # insert *string* into the tree
    #
    # ```
    # tst = TernarySearch::Tree.new
    # tst.insert("polygon") # => nil
    # ```
    def insert(string : String) : Nil
      insert(Char::Reader.new(string))
    end

    protected def insert(reader : Char::Reader) : Nil
      # Return early if the string is empty.
      return unless reader.has_next?

      # Assign the first character of the string locally.
      head = reader.current_char

      # Set the node's value to the first character of the string unless it's
      # already been set. We store the value locally so we don't have to do nil
      # checks.
      value = (self.value ||= head)

      if head < value
        # The first character of the string is less than value, we insert the
        # entire string into the left tree.

        # If @left is nil, create a new tree and assign it to the @left.
        left = (@left ||= Tree.new)

        # Add the string to the left tree.
        left.insert(reader)
      elsif head == value
        # Move the reader to the next character so that it points to the
        # second character of the string.
        reader.next_char

        if !reader.has_next?
          # This is the end of the string, therefore the end of the word.
          self.word_end = true
        else
          # If the first Char of string is equal to value, we insert the string
          # apart from it's first character into the equal tree.

          equal = (@equal ||= Tree.new)
          equal.insert(reader)
        end
      elsif head > value
        # The first character of the string is greater than value, we insert the
        # entire string into the right tree.

        right = (@right ||= Tree.new)
        right.insert(reader)
      end
    end

    # search for *string* in the tree
    #
    # ```
    # tst = TernarySearch::Tree.new
    # tst.insert("polygon")  # => nil
    # tst.insert("triangle") # => nil
    # tst.search("polygon")  # => true
    # tst.search("poly")     # => false
    # tst.search("triangle") # => true
    # ```
    def search(string : String) : Bool
      search(Char::Reader.new(string))
    end

    protected def search(reader : Char::Reader) : Bool
      # Bail out if the string is empty.
      return false unless reader.has_next?

      head = reader.current_char
      value = self.value

      # Bail out if the node value is empty
      return false unless value

      if head < value
        # The search term starts with a Char that is less than value.
        # Therefore:
        # - If the left tree from this node is empty, then the string is not in the tree.
        # - Otherwise, we need to keep searching down the left tree.
        if left = @left
          return left.search(reader)
        else
          return false
        end
      elsif head > value
        # The search term starts with a Char that is greater than value.
        # Therefore:
        # - If the right tree from this node is empty, then the string is not in the tree
        # - Otherwise, we need to keep searching down the right tree
        if right = @right
          return right.search(reader)
        else
          return false
        end
      else
        # The first Char of the search string is the same as value.
        # Therefore this is either the end of the search string or the start of it.

        # Move the reader to the next character so that it points to the
        # second character of the string.
        reader.next_char

        if !reader.has_next?
          # There is nothing more to look for.
          # Therefore, if this is an word end node, then we found it, otherwise we did not.
          return word_end?
        else
          # If @equal is nil, there is nothing more to search, so the string is not in the tree.
          # If @equal exists, we need to continue searching for the remainder of the string.
          if equal = @equal
            return equal.search(reader)
          else
            return false
          end
        end
      end
    end

    # Returns an array of all the words in the tree, in alphabetical order. It
    # is recommended that you do NOT use this on large trees because the memory
    # usage is large. Attempt to use `#each_word` if possible instead.
    #
    # ```
    # tst = TernarySearch::Tree.new
    # tst.insert("polygon")  # => nil
    # tst.insert("triangle") # => nil
    # tst.words => ["polygon", "triangle"]
    # ```
    def words
      output = Array(String).new
      each_word do |word|
        output << word
      end
      output
    end

    # Yields each word in the tree to the block, in alphabetical order.
    #
    # ```
    # tst = TernarySearch::Tree.new
    # tst.insert("polygon")  # => nil
    # tst.insert("triangle") # => nil
    # tst.words => ["polygon", "triangle"]
    # ```
    def each_word
      # The traversal stack holds the state required to traverse all the parent
      # nodes. It stores a reference to the parent node, and a boolean which is
      # true when the next tree to traverse is the equal tree and false when the
      # next tree to traverse is the right tree.
      traversal_stack = Array({Tree, Bool}).new

      # We start with the current tree and with an empty word stack.
      current = self
      word_stack = Array(Char).new

      loop do
        if current
          # If the node we're trying to visit exists, add it to the traversal
          # stack and traverse the left tree. As we're traversing the left tree,
          # we know that the next tree we have to traverse under this node is
          # the equal tree, so we set `traverse_equal` to true.
          traversal_stack << {current, true}
          current = current.left
        else
          # If the traversal stack is empty and there is no current node there's
          # nothing to do so we exit the loop.
          break if traversal_stack.empty?

          # Pop the parent node and `traverse_equal` from the stack.
          current, traverse_equal = traversal_stack.pop

          if traverse_equal
            # If `traverse_equal` is set, we are returning to traverse the equal
            # tree, but first we must add the node's value to the word stack, as
            # every node in the equal tree has this node's letter in. `value` is
            # never nil apart from when constructing the tree.
            word_stack << current.value.not_nil!

            # If this node is marked as the end of a word, we can yield the word
            # stack as a string to the block.
            yield word_stack.join if current.word_end?

            # Add this node to the stack again, but this time we set the boolean
            # to false because we want to traverse the right tree when we return
            # to this node.
            traversal_stack << {current, false}

            # We want to traverse the equal tree now.
            current = current.equal
          else
            # `traverse_equal` was not set so we want to traverse the right
            # tree. We don't add to the stack because we never need to return to
            # this node.
            current = current.right

            # Here we have just finished traversing the equal tree, so we pop
            # the value we pushed to the word stack earlier so it's not on the
            # stack when traversing the right tree.
            word_stack.pop
          end
        end
      end
    end

    # Compute the size of the longest word in the tree.
    def max_word_size
      # The minimum possible word size of a node is 1, as it always has a value.
      max = 1

      if left = @left
        # Find the size of the left tree and compare it to the maximum.
        size = left.max_word_size
        max = {max, size}.max
      end

      if equal = @equal
        # Find the size of the equal tree and compare it to the maximum. We add
        # one to the returned size because the equal tree includes the current
        # node's value in it's length.
        size = equal.max_word_size + 1
        max = {max, size}.max
      end

      if right = @right
        # Find the size of the right tree and compare it to the maximum.
        size = right.max_word_size
        max = {max, size}.max
      end

      max
    end
  end
end
