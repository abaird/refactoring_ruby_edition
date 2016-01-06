require 'spec_helper'

describe 'Video Store App' do
  it 'should have a Movie class' do
    movie = Movie.new('LOTR', 0)
    expect(movie.title).to eq('LOTR')
    expect(movie.price_code).to eq 0
    expect(Movie::REGULAR).to eq 0
    expect(Movie::NEW_RELEASE).to eq 1
    expect(Movie::CHILDRENS).to eq 2
  end

  it 'should have a Rental class' do
    rental = Rental.new('LOTR', 10)
    expect(rental.days_rented).to eq 10
    expect(rental.movie).to eq 'LOTR'
  end

  context 'Customer' do
    let(:customer) { Customer.new('Alan') }
    let(:foo_movie) { Movie.new('Foo', 0) }
    let(:bar_movie) { Movie.new('Bar', 0) }
    let(:regular_movie) { Movie.new('Regular Movie', 0) }
    let(:new_release_movie) { Movie.new('New Release', 1) }
    let(:childrens_movie) { Movie.new('Childrens Movie', 2) }
    let(:one_day_rental_regular) { Rental.new(regular_movie, 1) }
    let(:two_day_rental_regular) { Rental.new(regular_movie, 2) }
    let(:three_day_rental_regular) { Rental.new(regular_movie, 3) }
    let(:one_day_rental_new_release) { Rental.new(new_release_movie, 1) }
    let(:two_day_rental_new_release) { Rental.new(new_release_movie, 2) }
    let(:five_day_rental_new_release) { Rental.new(new_release_movie, 5) }
    let(:one_day_rental_childrens) { Rental.new(childrens_movie, 1) }
    let(:five_day_rental_childrens) { Rental.new(childrens_movie, 5) }
    it 'should be able to add one rental' do
      customer.add_rental(Rental.new(foo_movie, 10))
      # puts customer.statement
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/Foo\s+14\.0/)
      expect(customer.statement).to match(/14\.0$/)
      expect(customer.statement).to match(/1 frequent renter points/)
    end

    it 'should be able to add two rentals' do
      customer.add_rental(Rental.new(foo_movie, 10))
      customer.add_rental(Rental.new(bar_movie, 10))
      # puts customer.statement
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/Foo\s+14\.0/)
      expect(customer.statement).to match(/Bar\s+14\.0/)
      expect(customer.statement).to match(/owed is 28\.0$/)
      expect(customer.statement).to match(/2 frequent renter points/)
    end

    it 'regular rentals rented more than 2 days are at a higher rate' do
      customer.add_rental(three_day_rental_regular)
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/Regular Movie\s+3\.5$/)
      expect(customer.statement).to match(/owed is 3\.5$/)
      expect(customer.statement).to match(/1 frequent renter points/)
    end

    it 'regular rentals rented less than 2 days are $2' do
      customer.add_rental(two_day_rental_regular)
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/Regular Movie\s+2$/)
      expect(customer.statement).to match(/owed is 2$/)
      expect(customer.statement).to match(/1 frequent renter points/)
    end

    it 'new releases are charged at 3 times the number of days rented' do
      customer.add_rental(five_day_rental_new_release)
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/New Release\s+15$/)
      expect(customer.statement).to match(/owed is 15$/)
      expect(customer.statement).to match(/2 frequent renter points/)
    end

    it 'new releases are charged at 3 times the number of days rented (v2)' do
      customer.add_rental(two_day_rental_new_release)
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/New Release\s+6$/)
      expect(customer.statement).to match(/owed is 6$/)
      expect(customer.statement).to match(/2 frequent renter points/)
    end

    it 'frequent renter points get a bonus point for new releases' do
      customer.add_rental(two_day_rental_new_release)
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/New Release\s+6$/)
      expect(customer.statement).to match(/owed is 6$/)
      expect(customer.statement).to match(/2 frequent renter points/)
    end

    # also tests that childrens movies are free
    it 'only one frequent renter point for regular and childrens releases' do
      customer.add_rental(five_day_rental_childrens)
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/Childrens Movie\s+0$/)
      expect(customer.statement).to match(/owed is 0$/)
      expect(customer.statement).to match(/1 frequent renter points/)
    end

    it 'only calculates frequent rental points for one day rentals' do
      customer.add_rental(one_day_rental_childrens)
      customer.add_rental(one_day_rental_new_release)
      customer.add_rental(one_day_rental_regular)
      expect(customer.statement).to match('Rental Record for Alan')
      expect(customer.statement).to match(/Childrens Movie\s+0$/)
      expect(customer.statement).to match(/Regular Movie\s+2$/)
      expect(customer.statement).to match(/New Release\s+3$/)
      expect(customer.statement).to match(/owed is 5$/)
      expect(customer.statement).to match(/3 frequent renter points/)
    end
  end
end
