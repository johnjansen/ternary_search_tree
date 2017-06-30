class String
  def head
    return nil if self.empty?
    self[0]
  end

  def tail
    self[1..-1]
  end
end
