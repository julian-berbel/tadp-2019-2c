class ORM::Schema::Attribute
  attr_reader :attribute, :type, :validations, :default

  def initialize(attribute, type, default, validations)
    @attribute = attribute
    @type = type
    @default = default
    @validations = [ORM::Validation::Type.new(type), *build_validations(type, validations)] 
  end

  def build_validations(type, validations)
    validations.map { |key, value| ORM::Validation.build(key, value) }
  end

  def validate!(value)
    validations.each { |validation| validation.validate! attribute, value }
  end
end
