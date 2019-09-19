require_relative '../spec_helper'

describe ORM::Persistable do
  before do
    class SomeClass
      include ORM::Persistable

      has_one String, named: :name
    end
  end

  let(:some_object) { SomeClass.new }

  before { some_object.name = 'some name' }

  describe '.has_one' do
    context 'defines an accessor for the given attribute' do
      it { expect(some_object.name).to eq 'some name' } 
    end
  end

  describe '#save!' do
    before { some_object.save! }

    it { expect(some_object.id).to_not be_nil }
  end
end
