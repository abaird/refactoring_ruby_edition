class Movie
  REGULAR = 0
  NEW_RELEASE = 1
  CHILDRENS = 2

  attr_reader :title
  attr_accessor :price_code

  def initialize(title, price_code)
    @title = title
    @price_code = price_code
    case @price_code
    when 0
      extend RegularPricing
    when 1
      extend NewReleasePricing
    when 2
      extend ChildrensPricing
    end
  end

  def price(_days_rented)
    0
  end

  def frequent_renter_points(_days_rented)
    1
  end
end

module RegularPricing
  def price(days_rented)
    days_rented > 2 ? (2 + (days_rented - 2) * 1.5) : 2
  end
end

module NewReleasePricing
  def price(days_rented)
    days_rented * 3
  end

  def frequent_renter_points(days_rented)
    # add bonus for a two day new release rental
    days_rented > 1 ? 2 : 1
  end
end

module ChildrensPricing
  def price(days_rented)
    days_rented > 3 ? (1.5 + (days_rented - 3) * 1.5) : 1.5
  end
end

class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie = movie
    @days_rented = days_rented
  end
end

class Rentals
  attr_accessor :total_amount, :frequent_renter_points
  def initialize(rentals)
    @total_amount = 0
    @frequent_renter_points = 0
    @rentals = rentals
  end

  def process_collection(&block)
    @rentals.each do |rental|
      price = rental.movie.price(rental.days_rented)
      @frequent_renter_points += rental.movie.frequent_renter_points(rental.days_rented)
      block.call(rental.movie.title, price)
      @total_amount += price
    end
  end
end

class Customer
  def initialize(name)
    @name = name
    @rentals = []
  end

  def add_rental(arg)
    @rentals << arg
  end

  def statement
    TextReport.new(@name, @rentals).report
  end
end

class TextReport
  attr_reader :name
  def initialize(name, rentals)
    @name = name
    @rentals = Rentals.new(rentals)
    @result = "Rental Record for #{@name}\n"
  end

  def add_individual_rental(title, price)
    @result += "\t" + title + "\t" + price.to_s + "\n"
  end

  def report
    @rentals.process_collection { |title, price| add_individual_rental(title, price) }
    @result += "Amount owed is #{@rentals.total_amount}\n"
    @result += "You earned #{@rentals.frequent_renter_points} frequent renter points"
  end
end
