class ORM::Schema
  def initialize
    @attributes = {}
  end

  %i(each keys [] []=).each do |selector|
    define_method(selector) { |*args, &block| @attributes.send(selector, *args, &block) }
  end

  def defaults
    @attributes.transform_values(&:default).compact
  end
end

require_relative 'schema/attribute'
