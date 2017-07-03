class String
  def head
    return nil if self.empty?
    self[0]
  end

  def tail
    return "" if self.size < 2
    self[1..-1]
  end
end
