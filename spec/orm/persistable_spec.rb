require_relative '../spec_helper'

describe ORM::Persistable do
  describe 'methods' do
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

  describe 'transitivity' do
    context 'singleton methods propagate down inheritance/mixin tree' do
      before do
        module A
          include ORM::Persistable
          has_one String, named: :a
        end

        module B
          include ORM::Persistable
          has_one String, named: :b
        end

        class C
          include A
          include B
          has_one String, named: :c
        end

        class D < C
          has_one String, named: :d
        end

        module E
          include A
          include B
          has_one String, named: :e
        end

        class F
          include E
          has_one String, named: :f
        end

        class G < D
          has_one String, named: :g
        end
      end

      def searchable_attributes(klass)
        klass.methods.grep(/^find_by/).map { |it| it[/^find_by_\K.*/] }.sort
      end

      it { expect(searchable_attributes A).to eq %w(a id) }
      it { expect(searchable_attributes B).to eq %w(b id) }
      it { expect(searchable_attributes C).to eq %w(a b c id) }
      it { expect(searchable_attributes D).to eq %w(a b c d id) }
      it { expect(searchable_attributes E).to eq %w(a b e id) }
      it { expect(searchable_attributes F).to eq %w(a b e f id) }
      it { expect(searchable_attributes G).to eq %w(a b c d g id) }
    end
  end
end
