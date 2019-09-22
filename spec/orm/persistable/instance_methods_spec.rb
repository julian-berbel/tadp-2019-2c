require_relative '../../spec_helper'

describe ORM::Persistable::InstanceMethods do
  before do
    class SomeClass
      include ORM::Persistable

      has_one String, named: :name

      attr_accessor :some_non_persisting_attribute
    end

    class SomeOtherClass
      include ORM::Persistable

      has_one SomeClass, named: :something
    end
  end

  let(:some_object) { SomeClass.new }

  describe '#save!' do
    before do
      some_object.name = 'some name'
      some_object.save!
    end

    context 'object receives an id' do
      it { expect(some_object.id).to_not be_nil }
    end
    
    context 'creates a file in disk for table' do
      it { expect(File.exists?('db/someclass')).to be true }
    end

    context 'table contains object info' do
      it { expect(TADB::Table.new('someclass').entries.count).to eq 1 }
    end

    context 'stored object has only its persistable attributes' do
      it { expect(SomeClass.all_instances.first.name).to eq 'some name' }
      it { expect(SomeClass.all_instances.first.some_non_persisting_attribute).to be nil }
    end

    context 'nested persistable attributes' do
      before do
        TADB::DB.clear_all
        some_other_object = SomeOtherClass.new
        some_other_object.something = some_object
        some_other_object.save!
      end
    
      context 'cascades when saving persistable attributes' do
        it { expect(TADB::Table.new('someotherclass').entries.count).to eq 1 }
        it { expect(TADB::Table.new('someclass').entries.count).to eq 1 }
      end

      context 'stores nested persistable object\'s id in disk' do
        it { expect(TADB::Table.new('someotherclass').entries.first[:something]).to eq some_object.id }
      end
    end
  end

  describe '#refresh!' do
    context 'persisted object' do
      before do
        some_object.name = 'some name'
        some_object.save!

        some_object.name = 'some other name'
      end

      it { expect(some_object.name).to eq 'some other name' }

      context 'refreshes attributes from db' do
        before { some_object.refresh! }

        it { expect(some_object.name).to eq 'some name' }
      end
    end

    context 'fails if object hasn\'t been persisted yet' do
      it { expect { some_object.refresh! }.to raise_error 'This object has not been persisted yet!' }
    end
  end

  describe '#forget!' do
    let(:some_object) { SomeClass.new }

    before do
      some_object.name = 'some name'
      some_object.save!
      some_object.forget!
    end

    context 'deletes object from table' do
      it { expect(TADB::Table.new('someclass').entries.count).to eq 0 }
    end

    context 'clears object id' do
      it { expect(some_object.id).to be nil }
    end
  end

  context 'non persistable objects are not polluted' do
    it { expect { Object.new.save! }.to raise_error(NoMethodError) }
  end
end
