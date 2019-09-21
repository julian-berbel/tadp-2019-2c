module ORM::Persistable
end

require_relative 'persistable/class_methods'
require_relative 'persistable/instance_methods'

module ORM::Persistable
  def self.included(includer)
    includer.include(InstanceMethods)
    includer.extend(ClassMethods)

    super
  end

  extend ClassMethods
  
  has_one String, named: :id
end
