class ORM::Validation::NoBlank
  def initialize(enabled)
    @enabled = enabled
  end

  def validate!(attribute, value)
    return unless @enabled

    raise "Attribute #{attribute} can't be blank!" if value.nil? || value.empty?
  end
end
