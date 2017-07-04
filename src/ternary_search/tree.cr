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
    @value : (Char | Nil)  # the first character of the string represented by this tree
    @ending : Bool = false # a bool representing wether this is the end of a word

    @left : (Tree | Nil)  # a tree where the next node value is less than this value
    @equal : (Tree | Nil) # a tree where the next node value is equal to this value
    @right : (Tree | Nil) # a tree where the next node value is greater than this value

    # insert *string* into the tree
    #
    # ```
    # tst = TernarySearch::Tree.new
    # tst.insert("polygon") # => nil
    # ```
    def insert(string : String) : Nil
      # split the *string* into Char, String
      # e.g. "polygon".head => 'p' # Char
      #      "polygon".tail => "olygon" # String
      raw_head, tail = string.head, string.tail

      # bail out if the string is empty
      return nil if raw_head.nil?

      # assign the non-nil head locally
      head = raw_head.not_nil!

      # set @value, to the first Char of string
      # unless value is already set
      @value = head if @value.nil?

      # assign the non-nil value locally
      value = @value.not_nil!
      if head < value
        # if the first Char of string is less than value
        # if @left is nil, create a new tree and assign it to the @left
        @left = Tree.new if @left.nil?
        # add the string to the @left tree
        @left.not_nil!.insert(string)
      elsif head == value
        if tail.empty?
          # this is the end of the string
          # therefore the end of the word
          @ending = true
        else
          # if the first Char of string is equal to value
          # if @equal is nil, create a new tree and assign it to @equal
          @equal = Tree.new if @equal.nil?
          # insert the tail of the word into the tree
          # i.e.
          # ```
          # s = "string"
          # head = s[0]     # => 's'
          # tail = s[1..-1] # => "tring"
          # # now insert "tring" as a child of the 's' tree
          # ```
          @equal.not_nil!.insert(tail)
        end
      elsif head > value
        # if the first Char of string is greater than value
        # if @right is nil, create a new tree and assign it to the @right
        @right = Tree.new unless @right
        # add the string to the @right tree
        @right.not_nil!.insert(string)
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
      # split the *string* into Char, String
      # e.g. "polygon".head => 'p' # Char
      #      "polygon".tail => "olygon" # String
      raw_head, tail = string.head, string.tail

      # bail out if the string or value is empty
      return false if raw_head.nil? || @value.nil?

      # assign the non-nil head locally
      head = raw_head.not_nil!

      # assign the non-nil value locally
      value = @value.not_nil!

      if head < value
        # the search term starts with a Char that is less than value
        # therefore:
        # if the left tree from this node is empty, then the string is not in the tree
        # otherwise, we need to keep searching down the left tree
        return @left.nil? ? false : @left.not_nil!.search(string)
      elsif head > value
        # the search term starts with a Char that is greater than value
        # therefore:
        # if the right tree from this node is empty, then the string is not in the tree
        # otherwise, we need to keep searching down the right tree
        return @right.nil? ? false : @right.not_nil!.search(string)
      else
        # the first Char of the search string is the same as value
        # therefore:
        # this is EITHER: the end of the search string or the start of it
        if tail.empty?
          # if the tail there is nothing more to look for
          # therefore: if this is and @ending node, then we found it, otherwise we did not
          return @ending
        else
          # if @equal is nil, there is nothing more to search, so the string is not in the tree
          # otherwise: we are ok so far but need to continue searching for the remainder of the string
          return @equal.nil? ? false : @equal.not_nil!.search(tail)
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
      stack += @value.to_s unless @value.nil?

      if !@left.nil?
        ls = ""
        @left.not_nil!.words(output, ls)
      end
      output << stack if @ending
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
      length_ptr.value = depth if @ending && depth > length_ptr.value
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
