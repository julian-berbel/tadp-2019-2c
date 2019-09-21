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
    ancestors.flat_map { |ancestor| ancestor.own_persistable_attributes rescue nil }.compact
  end

  def own_persistable_attributes
    schema.keys
  end

  def from_h(hash)
    hash = hash.dup
    cascade_read!(hash)
    instance = new
    instance.assign_attributes(hash)
    instance
  end

  def schema
    @schema ||= {}
  end
  
  private

  def has_one(type, named:)
    attr_accessor named

    schema[named] = type

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

  def cascade_read!(hash)
    hash.each { |key, value| hash[key] = schema[key].find_by_id(value).first rescue value }
  end
end
