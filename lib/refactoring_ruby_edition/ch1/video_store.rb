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
end

module RegularPricing
  def price(days_rented)
    price = 2
    price += (days_rented - 2) * 1.5 if days_rented > 2
    price
  end

  def frequent_renter_points(_days_rented)
    1
  end
end

module NewReleasePricing
  def price(days_rented)
    price = 1.5
    price += (days_rented - 3) * 1.5 if days_rented > 3
    price
  end

  def frequent_renter_points(days_rented)
    frequent_renter_points = 1
    # add bonus for a two day new release rental
    frequent_renter_points += 1 if days_rented > 1
    frequent_renter_points
  end
end

module ChildrensPricing
  def price(_days_rented)
    0
  end

  def frequent_renter_points(_days_rented)
    1
  end
end

class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie = movie
    @days_rented = days_rented
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
    total_amount = 0
    frequent_renter_points = 0
    text_report = TextReport.new(@name)
    @rentals.each do |element|
      price = element.movie.price(element.days_rented)
      frequent_renter_points += element.movie.frequent_renter_points(element.days_rented)

      text_report.add_individual_rental(element.movie.title, price)
      total_amount += price
    end

    text_report.report(total_amount, frequent_renter_points)
  end
end

class TextReport
  attr_reader :name
  def initialize(name)
    @name = name
    @result = "Rental Record for #{@name}"
  end

  def add_individual_rental(title, price)
    @result += "\t" + title + "\t" + price.to_s + "\n"
  end

  def report(total_amount, frequent_renter_points)
    @result += "Amount owed is #{total_amount}\n"
    @result += "You earned #{frequent_renter_points} frequent renter points"
  end
end
