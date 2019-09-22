require_relative '../spec_helper'

describe 'Defaults' do
  before do
    class SomeClass
      include ORM::Persistable

      has_one String, named: :name, default: 'some name'
    end
  end

  let(:some_object) { SomeClass.new }

  context 'object is instanced with default values' do
    it { expect(some_object.name).to eq 'some name' }
  end

  context 'if object is saved with no value then default is set' do
    before do
      some_object.name = nil
      some_object.save!
      some_object.refresh!
    end

    it { expect(some_object.name).to eq 'some name' }
  end
end
