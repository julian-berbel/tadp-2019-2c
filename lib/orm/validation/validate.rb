class ORM::Validation::Validate
  def initialize(condition)
    @condition = condition
  end

  def validate!(attribute, value)
    raise 'Failed custom validation!' unless value.instance_eval &@condition
  end
end
