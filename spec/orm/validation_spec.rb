require_relative '../spec_helper'

describe ORM::Validation do
  describe ORM::Validation::From do
    before do
      class SomeClass
        include ORM::Persistable

        has_one Numeric, named: :age, from: 18

        def initialize(age)
          @age = age
        end
      end
    end

    context 'fails when attribute is under specified bound' do
      it { expect { SomeClass.new(15).validate! }.to raise_error 'Expected attribute age to be over 18!' }
      it { expect { SomeClass.new(20).validate! }.to_not raise_error }
    end
  end

  describe ORM::Validation::NoBlank do
    before do
      class SomeClass
        include ORM::Persistable

        has_one String, named: :name, no_blank: true
        has_one String, named: :non_validating_attribute, no_blank: false
      end
    end

    let(:some_object) { SomeClass.new }

    context 'fails when attribute is empty string' do
      before do
        some_object.name = ''
        some_object.non_validating_attribute = 'something'
      end
      
      it { expect { some_object.validate! }.to raise_error 'Attribute name can\'t be blank!' }
    end

    context 'does not fail when validation passes or is disabled' do
      before do
        some_object.name = 'something'
        some_object.non_validating_attribute = ''
      end
      
      it { expect { some_object.validate! }.to_not raise_error }
    end
  end

  describe ORM::Validation::To do
    before do
      class SomeClass
        include ORM::Persistable

        has_one Numeric, named: :age, to: 60

        def initialize(age)
          @age = age
        end
      end
    end

    context 'fails when attribute is under specified bound' do
      it { expect { SomeClass.new(65).validate! }.to raise_error 'Expected attribute age to be under 60!' }
      it { expect { SomeClass.new(55).validate! }.to_not raise_error }
    end
  end

  describe ORM::Validation::Type do
    before do
      class SomeClassWithABoolean
        include ORM::Persistable

        has_one Boolean, named: :some_boolean

        def initialize(some_boolean)
          @some_boolean = some_boolean
        end
      end

      class SomeClassWithAString
        include ORM::Persistable

        has_one String, named: :name

        def initialize(name)
          @name = name
        end
      end

      class SomeClass
      end

      class SomeClassWithAnObject
        include ORM::Persistable

        has_one SomeClass, named: :some_object

        def initialize(some_object)
          @some_object = some_object
        end        
      end
    end

    context 'Boolean allows saving only booleans' do
      it { expect { SomeClassWithABoolean.new(true).validate! }.to_not raise_error }
      it { expect { SomeClassWithABoolean.new(false).validate! }.to_not raise_error }
      it { expect { SomeClassWithABoolean.new('something').validate! }.to raise_error 'Expected attribute some_boolean of type: Boolean, but got: String!' }
    end

    context 'String allows saving only strings' do
      it { expect { SomeClassWithAString.new('something').validate! }.to_not raise_error }
      it { expect { SomeClassWithAString.new('').validate! }.to_not raise_error }
      it { expect { SomeClassWithAString.new(123).validate! }.to raise_error 'Expected attribute name of type: String, but got: Integer!' }
    end

    context 'An object class allows saving only objects of said class' do
      it { expect { SomeClassWithAnObject.new(SomeClass.new).validate! }.to_not raise_error }
      it { expect { SomeClassWithAnObject.new(Object.new).validate! }.to raise_error 'Expected attribute some_object of type: SomeClass, but got: Object!' }
    end
  end

  describe ORM::Validation::Validate do
    before do
      class SomeClass
        include ORM::Persistable

        has_one Boolean, named: :some_boolean, validate: proc { self }

        def initialize(some_boolean)
          @some_boolean = some_boolean
        end
      end
    end

    context 'run validation in object context and fails when result is falsy' do
      it { expect { SomeClass.new(true).validate! }.to_not raise_error }
      it { expect { SomeClass.new(false).validate! }.to raise_error 'Failed custom validation!' }
    end
  end

  context 'allows setting multiple validations for same value' do
    before do
      class SomeClass
        include ORM::Persistable

        has_one Numeric, named: :age, from: 18, to: 60, validate: proc { self.even? }

        def initialize(age)
          @age = age
        end
      end
    end

    context 'it passes only when all validations pass at the same time' do
      it { expect { SomeClass.new(16).validate! }.to raise_error 'Expected attribute age to be over 18!' }
      it { expect { SomeClass.new(64).validate! }.to raise_error 'Expected attribute age to be under 60!' }
      it { expect { SomeClass.new(35).validate! }.to raise_error 'Failed custom validation!' }
      it { expect { SomeClass.new(30).validate! }.to_not raise_error }
    end
  end
end
