module ORM::Persistable::ClassMethods
  ORM::Persistable::ClassMethods::MODULE_PROPAGATION_HACK = proc do |includer|
    m = Module.new.include @persistence_module
    includer.extend m
    includer.instance_variable_set :@persistence_module, m

    if includer.class == Module
      includer.define_singleton_method :included, &ORM::Persistable::ClassMethods::MODULE_PROPAGATION_HACK
    end
  end
  
  def self.extended(extender)
    extender.instance_variable_set(:@persistence_module, self.dup)
  end

  define_method :included, &MODULE_PROPAGATION_HACK

  def inherited(subclass)
    m = Module.new.include @persistence_module
    subclass.extend m
    subclass.instance_variable_set(:@persistence_module, m)

    @children ||= []

    @children << subclass
  end

  def has_one(type, named:)
    attr_accessor named

    @persistable_attributes ||= []
    @persistable_attributes << named

    define_find_method(named)
  end

  alias has_many has_one

  def all_instances
    own_entries + @children.to_a.flat_map(&:all_instances)
  end

  def own_entries
    table.entries.map { |entry| from_h(entry) }
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

  def define_find_method(named)
    @persistence_module.send :define_method, "find_by_#{named}" do |value|
      all_instances.select { |instance| instance.instance_variable_get("@#{named}") == value }
    end
  end
end
