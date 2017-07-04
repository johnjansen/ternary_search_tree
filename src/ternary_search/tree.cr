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
    # Contains the Char value of this tree node with the highest bit set if
    # the node represents the end of a word. This is done to reduce the size of
    # this class.
    @combined_value : UInt32 = 0_u32

    @left : (Tree | Nil)  # a tree where the next node value is less than this value
    @equal : (Tree | Nil) # a tree where the next node value is equal to this value
    @right : (Tree | Nil) # a tree where the next node value is greater than this value

    def value : Char?
      # Take the last 31 bits and convert to Char
      char = (@combined_value & ~(1 << 31)).chr

      # We use '\0' to signal a nil char value
      char == '\0' ? nil : char
    end

    def value=(char : Char)
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

    def word_end=(word_end : Bool)
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

    # returns an array of words in the TST
    # it is recommended that you do NOT use this on large TST's
    # TODO investigate an iterator
    # TODO workaround the yield issue of infinite inlining
    #      possibly with a Proc?
    #
    # ```
    # tst = TernarySearch::Tree.new
    # tst.insert("polygon")  # => nil
    # tst.insert("triangle") # => nil
    # tst.words => ["polygon", "triangle"]
    # ```
    def words(output : Array(String) = [] of String, stack = "")
      stack += value.to_s unless value.nil?

      if !@left.nil?
        ls = ""
        @left.not_nil!.words(output, ls)
      end
      output << stack if word_end?
      if !@equal.nil?
        @equal.not_nil!.words(output, stack)
      end
      if !@right.nil?
        rs = ""
        @right.not_nil!.words(output, rs)
      end

      output
    end

    # compute the length of the longest word in the TST
    def max_word_length(length_ptr : (Pointer(Int32) | Nil) = nil, depth : Int32 = 0)
      # since this is recursive,
      # and we want to start with nothing passed in
      # and we need a shared variable to hold the max length
      # we create a var `l` and get the pointer to it
      # then throw the pointer around from here on out

      # keep it out in the open so it doesnt get GC'd
      # TODO determine if this a correct assumption
      l = 0

      # get a pointer to `l` if its not already defined
      length_ptr = pointerof(l) if length_ptr.is_a?(Nil) || length_ptr.null?

      # increment the value of the var `l` that is at the end
      # of the pointer `length_ptr` if the current depth
      # returns a word, and the depth is greater than the current length
      length_ptr.value = depth if word_end? && depth > length_ptr.value
      depth += 1

      # recurse the left
      if !@left.nil?
        @left.not_nil!.max_word_length(length_ptr, depth)
      end

      # recurse the direct children
      if !@equal.nil?
        @equal.not_nil!.max_word_length(length_ptr, depth)
      end

      # recurse the right
      if !@right.nil?
        @right.not_nil!.max_word_length(length_ptr, depth)
      end

      # return the value stored in the var at the end of the pointer
      return length_ptr.value
    end
  end
end
