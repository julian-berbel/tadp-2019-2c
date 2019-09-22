require_relative '../../spec_helper'

describe ORM::Persistable::ClassMethods do
  before do
    class SomeClass
      include ORM::Persistable

      has_one String, named: :name

      attr_accessor :some_non_persisting_attribute
    end
  end

  let(:some_object) { SomeClass.new }

  describe '.has_one' do
    context 'defines an accessor for the given attribute' do
      before { some_object.name = 'some name' }

      it { expect(some_object.name).to eq 'some name' }
    end

    context 'overrides type if same attribute is defined twice' do
      before do
        class SomeClass
          has_one Numeric, named: :name
        end
      end

      it { expect(SomeClass.schema[:name].type).to eq Numeric }
    end

    context 'allows setting type as Boolean' do
      before do
        class SomeClass
          has_one Boolean, named: :some_boolean
        end
      end

      it { expect(SomeClass.schema[:some_boolean].type).to eq Boolean }
    end      
  end

  context 'multiple persisted objects' do
    before do
      some_object.name = 'some name'
      some_object.save!

      some_other_object = SomeClass.new
      some_other_object.name = 'some other name'
      some_other_object.save!
    end

    describe '.all_instances' do
      context 'it retrieves all instances from database' do
        it { expect(SomeClass.all_instances.count).to eq 2 }
        it { expect(SomeClass.all_instances.first.class).to eq SomeClass }
      end
    end

    describe '.find_by_' do
      context 'a find_by method is defined for persistible attributes' do
        it { expect(SomeClass.respond_to? :find_by_name).to be true }
        it { expect(SomeClass.respond_to? :find_by_age).to be false }
      end

      context 'it retrieves instances with attribute value equal to given one' do
        it { expect(SomeClass.find_by_name('some name').count).to eq 1 }
        it { expect(SomeClass.find_by_name('some name').first.class).to eq SomeClass }
        it { expect(SomeClass.find_by_name('some other name').count).to eq 1 }
        it { expect(SomeClass.find_by_name('yet another name').count).to eq 0 }
      end
    end
  end
end
