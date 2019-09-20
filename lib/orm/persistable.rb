module ORM::Persistable
  def self.included(includer)
    includer.include(InstanceMethods)
    includer.extend(ClassMethods)
  end

  module ClassMethods
    def self.extended(extender)
      extender.instance_variable_set(:@persistable_attributes, [])
    end

    def has_one(type, named:)
      attr_accessor named

      @persistable_attributes << named

      define_find_method(named)
    end

    alias has_many has_one

    def all_instances
      table.entries.map { |entry| from_h(entry) }
    end

    def table
      @table ||= TADB::Table.new(name.downcase)
    end

    def persistable_attributes
      ancestors.flat_map { |ancestor| ancestor.instance_variable_get :@persistable_attributes }.compact
    end

    def from_h(hash)
      instance = new
      instance.assign_attributes(hash)
      instance
    end

    private

    def define_find_method(named)
      define_singleton_method "find_by_#{named}" do |value|
        all_instances.select { |instance| instance.instance_variable_get("@#{named}") == value }
      end
    end
  end

  module InstanceMethods
    def save!
      @id = table.insert(to_h)
    end

    def refresh!
      assign_attributes(self.class.find_by_id id)
    end

    def forget!
      table.delete id
      @id = nil
    end

    def to_h
      self.class.persistable_attributes.map { |attribute| [attribute, instance_variable_get("@#{attribute}")] }.to_h
    end

    def assign_attributes(assignments)
      assignments.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    private

    def table
      self.class.table
    end
  end

  extend ClassMethods
  
  has_one String, named: :id
end
