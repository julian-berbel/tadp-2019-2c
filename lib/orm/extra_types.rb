module Boolean
  def self.===(object)
    TrueClass === object || FalseClass === object
  end
end
