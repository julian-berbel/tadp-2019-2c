class ORM::Validation::To
  def initialize(bound)
    @bound = bound
  end

  def validate!(attribute, value)
    raise "Expected attribute #{attribute} to be under #{bound}!" if value > bound
  end
end
