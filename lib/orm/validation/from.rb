class ORM::Validation::From
  def initialize(bound)
    @bound = bound
  end

  def validate!(attribute, value)
    raise "Expected attribute #{attribute} to be over #{@bound}!" if value < @bound
  end
end
