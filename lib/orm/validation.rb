module ORM::Validation
  def self.build(key, value)
    case key
    when :from
      From
    when :no_blank
      NoBlank
    when :to
      To
    when :type
      Type
    when :validate
      Validate
    end.new(value)
  end
end

require_relative 'validation/from'
require_relative 'validation/no_blank'
require_relative 'validation/to'
require_relative 'validation/type'
require_relative 'validation/validate'
