module Boolean
  def ===(object)
    TrueClass === object || FalseClass === object
  end
end
