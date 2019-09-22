module ORM::Persistable::InstanceMethods
  def save!
    validate!

    hash = self.class.schema.defaults.merge(to_h.compact)

    hash.transform_values! { |value| cascade_save! value }
    @id = table.insert(hash)
  end

  def refresh!
    raise 'This object has not been persisted yet!' unless id
    old = self.class.find_by_id(id).first.to_h
    assign_attributes(old)
    self
  end

  def forget!
    table.delete id
    @id = nil
  end

  def validate!
    self.class.schema.each do |attribute, attr_schema|
      value = instance_variable_get("@#{attribute}")
      attr_schema.validate!(value)
    end
  end

  def to_h
    self.class.persistable_attributes
              .map { |attribute| [attribute, instance_variable_get("@#{attribute}")] }
              .to_h
  end

  def assign_attributes(assignments)
    assignments.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  private

  def cascade_save!(value)
    value.save! rescue value
  end

  def table
    self.class.table
  end
end
