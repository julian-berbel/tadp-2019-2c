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

    def has_many(type, named:)
      attr_accessor named

      @persistable_attributes << named

      define_find_method(named)
    end

    def all_instances
      table.entries.map { |entry|  }
    end

    def table
      @table ||= TADB::Table.new(name.downcase)
    end

    def persistable_attributes
      parent = ancestors[1]

      if parent.respond_to?(:persistable_attributes)
        @persistable_attributes + parent.persistable_attributes
      else
        @persistable_attributes
      end
    end

    private

    def define_find_method(named)
      define_singleton_method "find_by_#{named}" do |value|
        table.entries.select { |entry| entry.instance_variable_get(named) == value }
      end
    end
  end

  module InstanceMethods
    def save!
      id = table.insert(as_json)
      self.id = id
    end

    def refresh!
    end

    def forget!
    end

    private

    def as_json
      self.class.persistable_attributes.map { |attribute| [attribute, instance_variable_get("@#{attribute}")] }.to_h
    end

    def table
      self.class.table
    end
  end

  extend ClassMethods
  
  has_one String, named: :id
end
