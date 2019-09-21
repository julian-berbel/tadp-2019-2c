module ORM::Persistable::ClassMethods
  ORM::Persistable::ClassMethods::MODULE_SINGLETON_PROPAGATION_HACK = proc do |includer|
    includer.extend ORM::Persistable::ClassMethods

    includer.add_persistence_module persistence_module

    children << includer

    overridable_hook = includer.class == Module ? :included : :inherited
    
    includer.define_singleton_method overridable_hook, &ORM::Persistable::ClassMethods::MODULE_SINGLETON_PROPAGATION_HACK
  end

  def add_persistence_module(parent_persistence_module)
    persistence_module.include parent_persistence_module
    extend persistence_module
  end
  
  def all_instances
    own_entries + children.to_a.flat_map(&:all_instances)
  end

  def table
    @table ||= TADB::Table.new(name.downcase)
  end

  def persistable_attributes
    ancestors.flat_map { |ancestor| ancestor.instance_variable_get :@persistable_attributes }.compact
  end

  def from_h(hash)
    hash = hash.dup
    type = hash.delete(:type)
    instance = type ? Object.const_get(type).new : new
    instance.assign_attributes(hash)
    instance
  end

  private

  def has_one(type, named:)
    attr_accessor named

    own_persistable_attributes << named

    define_find_method(named)
  end

  alias has_many has_one

  def own_entries
    table.entries.map { |entry| from_h(entry) }
  end

  def define_find_method(named)
    persistence_module.send :define_method, "find_by_#{named}" do |value|
      all_instances.select { |instance| instance.instance_variable_get("@#{named}") == value }
    end
  end

  def children
    @children ||= []
  end

  def persistence_module
    @persistence_module ||= Module.new
  end

  def own_persistable_attributes
    @persistable_attributes ||= []
  end
end
