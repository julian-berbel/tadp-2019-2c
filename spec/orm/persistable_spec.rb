require_relative '../spec_helper'

describe ORM::Persistable do

  describe 'methods' do
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

  describe 'transitivity' do
    context 'subclass has parent\'s attributes too' do
      before do
        class SomeClass
          include ORM::Persistable

          has_one String, named: :attribute          
        end
        
        class SomeSubClass < SomeClass
          has_one String, named: :another_attribute          
        end
      end

      it { expect(SomeSubClass.respond_to? 'find_by_attribute').to be true }
      it { expect(SomeSubClass.respond_to? 'find_by_another_attribute').to be true }
    end

    context 'it works with mixins too' do
      before do
        module SomeModule
          include ORM::Persistable

          has_one String, named: :attribute
        end

        class SomeClass
          include SomeModule

          has_one String, named: :another_attribute
        end
      end

      it { expect(SomeClass.respond_to? 'find_by_attribute').to be true }
      it { expect(SomeClass.respond_to? 'find_by_another_attribute').to be true }
    end

    context 'it propagates' do
      before do
        module SomeModule
          include ORM::Persistable

          has_one String, named: :attribute
        end

        module SomeOtherModule
          include SomeModule

          has_one String, named: :another_attribute
        end

        class SomeClass
          include SomeOtherModule

          has_one String, named: :yet_another_attribute
        end
      end

      it { expect(SomeModule.respond_to? 'find_by_attribute').to be true }
      it { expect(SomeModule.respond_to? 'find_by_another_attribute').to be false }
      it { expect(SomeOtherModule.respond_to? 'find_by_attribute').to be true }
      it { expect(SomeOtherModule.respond_to? 'find_by_another_attribute').to be true }
      it { expect(SomeClass.respond_to? 'find_by_attribute').to be true }
      it { expect(SomeClass.respond_to? 'find_by_another_attribute').to be true }
      it { expect(SomeClass.respond_to? 'find_by_yet_another_attribute').to be true }
    end
  end
end
