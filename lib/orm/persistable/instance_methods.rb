module ORM::Persistable::InstanceMethods
  def save!
    hash = to_h
    hash.transform_values! { |value| cascade_save! value }
    @id = table.insert(hash)
  end

  def refresh!
    old = self.class.find_by_id(id).first.to_h
    old.delete :type
    assign_attributes(old)
    self
  end

  def forget!
    table.delete id
    @id = nil
  end

  def to_h
    self.class.persistable_attributes
              .map { |attribute| [attribute, instance_variable_get("@#{attribute}")] }
              .to_h
              .merge(type: self.class.name)
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
