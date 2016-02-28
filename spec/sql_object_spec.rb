require 'sql_object'
require 'db_connection'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Dog < SQLObject
      end
    end

    after(:each) do
      Object.send(:remove_const, :Dog)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Dog.table_name).to eq('dogs')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class Human < SQLObject
          self.table_name = 'humans'
        end

        expect(Human.table_name).to eq('humans')

        Object.send(:remove_const, :Human)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Dog.columns).to eq([:id, :name, :owner_id])
      end

      it 'only queries the DB once' do
        expect(DBConnection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Dog.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash byref' do
        dog_attributes = {name: 'Doge'}
        c = Dog.new
        c.instance_variable_set('@attributes', dog_attributes)

        expect(c.attributes).to equal(dog_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        c = Dog.new

        expect(c.instance_variables).not_to include(:@attributes)
        expect(c.attributes).to eq({})
        expect(c.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Dog < SQLObject
        self.finalize!
      end

      class Human < SQLObject
        self.table_name = 'humans'

        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Dog)
      Object.send(:remove_const, :Human)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        c = Dog.new
        expect(c.respond_to? :something).to be false
        expect(c.respond_to? :name).to be true
        expect(c.respond_to? :id).to be true
        expect(c.respond_to? :owner_id).to be true
      end

      it 'creates setter methods for each column' do
        c = Dog.new
        c.name = "Bailey Sladkey"
        c.id = 209
        c.owner_id = 2
        expect(c.name).to eq 'Bailey Sladkey'
        expect(c.id).to eq 209
        expect(c.owner_id).to eq 2
      end

      it 'created getter methods read from attributes hash' do
        c = Dog.new
        c.instance_variable_set(:@attributes, {name: "Bailey Sladkey"})
        expect(c.name).to eq 'Bailey Sladkey'
      end

      it 'created setter methods use attributes hash to store data' do
        c = Dog.new
        c.name = "Bailey Sladkey"

        expect(c.instance_variables).to include(:@attributes)
        expect(c.instance_variables).not_to include(:@name)
        expect(c.attributes[:name]).to eq 'Bailey Sladkey'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params' do
        # We have to set method expectations on the dog object *before*
        # #initialize gets called, so we use ::allodoge to create a
        # blank Dog object first and then call #initialize manually.
        c = Dog.allocate

        expect(c).to receive(:name=).with('Doge Coin')
        expect(c).to receive(:id=).with(100)
        expect(c).to receive(:owner_id=).with(4)

        c.send(:initialize, {name: 'Doge Coin', id: 100, owner_id: 4})
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Dog.new(favorite_band: 'The Beatles')
        end.to raise_error "unknown attribute 'favorite_band'"
      end
    end

    describe '::all, ::parse_all' do
      it '::all returns all the rows' do
        dogs = Dog.all
        expect(dogs.count).to eq(5)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { name: 'dog1', owner_id: 1 },
          { name: 'dog2', owner_id: 2 }
        ]

        dogs = Dog.parse_all(hashes)
        expect(dogs.length).to eq(2)
        hashes.each_index do |i|
          expect(dogs[i].name).to eq(hashes[i][:name])
          expect(dogs[i].owner_id).to eq(hashes[i][:owner_id])
        end
      end

      it '::all returns a list of objects, not hashes' do
        dogs = Dog.all
        dogs.each { |dog| expect(dog).to be_instance_of(Dog) }
      end
    end

    describe '::find' do
      it 'fetches single objects by id' do
        c = Dog.find(1)

        expect(c).to be_instance_of(Dog)
        expect(c.id).to eq(1)
      end

      it 'returns nil if no object has the given id' do
        expect(Dog.find(123)).to be_nil
      end
    end

    describe '#attribute_values' do
      it 'returns array of values' do
        dog = Dog.new(id: 123, name: 'dog1', owner_id: 1)

        expect(dog.attribute_values).to eq([123, 'dog1', 1])
      end
    end

    describe '#insert' do
      let(:dog) { Dog.new(name: 'Doge', owner_id: 1) }

      before(:each) { dog.insert }

      it 'inserts a new record' do
        expect(Dog.all.count).to eq(6)
      end

      it 'sets the id once the new record is saved' do
        expect(dog.id).to eq(DBConnection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        # pull the dog again
        dog2 = Dog.find(dog.id)

        expect(dog2.name).to eq('Doge')
        expect(dog2.owner_id).to eq(1)
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        human = Human.find(2)

        human.fname = 'Tommy'
        human.lname = 'Duek'
        human.update

        # pull the human again
        human = Human.find(2)
        expect(human.fname).to eq('Tommy')
        expect(human.lname).to eq('Duek')
      end
    end

    describe '#save' do
      it 'calls #insert when record does not exist' do
        human = Human.new
        expect(human).to receive(:insert)
        human.save
      end

      it 'calls #update when record already exists' do
        human = Human.find(1)
        expect(human).to receive(:update)
        human.save
      end
    end
  end
end
