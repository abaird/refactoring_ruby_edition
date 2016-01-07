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
    let(:expected_report_data) { ReportData.new('Alan') }
    it 'should be able to add one rental' do
      customer.add_rental(Rental.new(foo_movie, 10))
      # puts customer.statement
      expected_report_data.frequent_renter_points = 1
      expected_report_data.total = 14.0
      expected_report_data.add_movie('Foo', 14.0)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'should be able to add two rentals' do
      customer.add_rental(Rental.new(foo_movie, 10))
      customer.add_rental(Rental.new(bar_movie, 10))
      # puts customer.statement
      expected_report_data.frequent_renter_points = 2
      expected_report_data.total = 28.0
      expected_report_data.add_movie('Foo', 14.0)
      expected_report_data.add_movie('Bar', 14.0)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'regular rentals rented more than 2 days are at a higher rate' do
      customer.add_rental(three_day_rental_regular)
      expected_report_data.frequent_renter_points = 1
      expected_report_data.total = 3.5
      expected_report_data.add_movie('Regular Movie', 3.5)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'regular rentals rented less than 2 days are $2' do
      customer.add_rental(two_day_rental_regular)
      expected_report_data.frequent_renter_points = 1
      expected_report_data.total = 2
      expected_report_data.add_movie('Regular Movie', 2)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'new releases are charged at 3 times the number of days rented' do
      customer.add_rental(five_day_rental_new_release)
      expected_report_data.frequent_renter_points = 2
      expected_report_data.total = 15
      expected_report_data.add_movie('New Release', 15)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'new releases are charged at 3 times the number of days rented (v2)' do
      customer.add_rental(two_day_rental_new_release)
      expected_report_data.frequent_renter_points = 2
      expected_report_data.total = 6
      expected_report_data.add_movie('New Release', 6)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'frequent renter points get a bonus point for new releases' do
      customer.add_rental(two_day_rental_new_release)
      expected_report_data.frequent_renter_points = 2
      expected_report_data.total = 6
      expected_report_data.add_movie('New Release', 6)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'complicated formula for childrens releases over 3 days' do
      customer.add_rental(five_day_rental_childrens)
      expected_report_data.frequent_renter_points = 1
      expected_report_data.total = 4.5
      expected_report_data.add_movie('Childrens Movie', 4.5)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it '$1.5 for childrens releases less than 3 days' do
      customer.add_rental(one_day_rental_childrens)
      expected_report_data.frequent_renter_points = 1
      expected_report_data.total = 1.5
      expected_report_data.add_movie('Childrens Movie', 1.5)
      expect(customer.statement).to match_text_report(expected_report_data)
    end

    it 'only calculates frequent rental points for one day rentals' do
      customer.add_rental(one_day_rental_regular)
      customer.add_rental(one_day_rental_new_release)
      customer.add_rental(one_day_rental_childrens)
      expected_report_data.frequent_renter_points = 3
      expected_report_data.total = 6.5
      expected_report_data.add_movie('Regular Movie', 2)
      expected_report_data.add_movie('New Release', 3)
      expected_report_data.add_movie('Childrens Movie', 1.5)
      expect(customer.statement).to match_text_report(expected_report_data)
    end
  end
end
