require_relative '../spec_helper'

describe ORM::Persistable do
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
