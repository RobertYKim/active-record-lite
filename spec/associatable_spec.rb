require 'associatable'

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Dog < SQLObject
      belongs_to :human, foreign_key: :owner_id

      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      has_many :dogs, foreign_key: :owner_id
      belongs_to :house

      finalize!
    end

    class House < SQLObject
      has_many :humans

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:spot) { Dog.find(1) }
    let(:peter) { Human.find(1) }

    it 'fetches `human` from `Dog` correctly' do
      expect(spot).to respond_to(:human)
      human = spot.human

      expect(human).to be_instance_of(Human)
      expect(human.fname).to eq('Peter')
    end

    it 'fetches `house` from `Human` correctly' do
      expect(peter).to respond_to(:house)
      house = peter.house

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('432 Park Ave')
    end

    it 'returns nil if no associated object' do
      stray_dog = Dog.find(5)
      expect(stray_dog.human).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:peter) { Human.find(3) }
    let(:peter_house) { House.find(2) }

    it 'fetches `dogs` from `Human`' do
      expect(peter).to respond_to(:dogs)
      dogs = peter.dogs

      expect(dogs.length).to eq(2)

      expected_dog_names = %w(Lassie Pluto)
      2.times do |i|
        dog = dogs[i]

        expect(dog).to be_instance_of(Dog)
        expect(dog.name).to eq(expected_dog_names[i])
      end
    end

    it 'fetches `humans` from `House`' do
      expect(peter_house).to respond_to(:humans)
      humans = peter_house.humans

      expect(humans.length).to eq(1)
      expect(humans[0]).to be_instance_of(Human)
      expect(humans[0].fname).to eq('Jonathan')
    end

    it 'returns an empty array if no associated items' do
      dogless_human = Human.find(4)
      expect(dogless_human.dogs).to eq([])
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Dog
        has_one_through :home, :human, :house

        self.finalize!
      end
    end

    let(:dog) { Dog.find(1) }

    it 'adds getter method' do
      expect(dog).to respond_to(:home)
    end

    it 'fetches associated `home` for a `Dog`' do
      house = dog.home

      expect(house).to be_instance_of(House)
      expect(house.address).to eq('432 Park Ave')
    end
  end

  describe '#has_many_through' do
    before(:all) do
      class House
        has_many_through :dogs, :humans, :dogs

        self.finalize!
      end
    end

    let(:house) { House.find(1) }

    it 'adds getter method' do
      expect(house).to respond_to(:dogs)
    end

    it 'fetches associated `dogs` for a `House`' do
      dogs = house.dogs
      expect(dogs.length).to eq(2)

      expected_dog_names = %w(Spot Clifford)
      2.times do |i|
        dog = dogs[i]

        expect(dog).to be_instance_of(Dog)
        expect(dog.name).to eq(expected_dog_names[i])
      end
    end
  end
end
