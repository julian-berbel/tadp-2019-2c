class ORM::Validation::Type
  def initialize(type)
    @type = type
  end

  def validate!(attribute, value)
    expected = value.class

    raise "Expected attribute #{attribute} of type: #{expected}, but got: #{@type}!" unless @type == expected
    
    value.validate! if ORM::Persistable === value
  end
end
