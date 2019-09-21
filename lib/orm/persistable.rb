module ORM::Persistable
end

require_relative 'persistable/class_methods'
require_relative 'persistable/instance_methods'

module ORM::Persistable
  def self.included(includer)
    includer.include(InstanceMethods)
    instance_exec includer, &ORM::Persistable::ClassMethods::MODULE_SINGLETON_PROPAGATION_HACK
  end

  extend ClassMethods
  
  has_one String, named: :id
end
