module ORM::Persistable::InstanceMethods
  def save!
    validate!
    
    hash = to_h
    hash.transform_values! { |value| cascade_save! value }
    @id = table.insert(hash)
  end

  def refresh!
    old = self.class.find_by_id(id).first.to_h
    assign_attributes(old)
    self
  end

  def forget!
    table.delete id
    @id = nil
  end

  def validate!
    self.class.schema.each do |attribute, expected|
      value = instance_variable_get("@#{attribute}")
      value.validate! if ORM::Persistable === value

      actual = value.class
      raise "Expected attribute #{attribute} of type: #{expected}, but got: #{actual}!" unless actual == expected
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
