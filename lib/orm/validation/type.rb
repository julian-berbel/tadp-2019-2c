class ORM::Validation::Type
  def initialize(type)
    @type = type
  end

  def validate!(attribute, value)
    raise "Expected attribute #{attribute} of type: #{@type}, but got: #{value.class}!" unless @type === value
    
    value.validate! if ORM::Persistable === value
  end
end
