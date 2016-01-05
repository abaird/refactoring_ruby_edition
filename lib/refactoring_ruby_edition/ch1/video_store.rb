class Movie
  REGULAR = 0
  NEW_RELEASE = 1
  CHILDRENS = 2

  attr_reader :title
  attr_accessor :price_code

  def initialize(title, price_code)
    @title = title
    @price_code = price_code
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
    result = "Rental Record for #{@name}\n"
    @rentals.each do |element|
      price = price_per_rental(element)
      frequent_renter_points += add_frequent_renter_points(element)

      # show figures for this rental
      result += "\t" + element.movie.title + "\t" + price.to_s + "\n"
      total_amount += price
    end

    # add footer lines
    result += "Amount owed is #{total_amount}\n"
    result += "You earned #{frequent_renter_points} frequent renter points"
    result
  end

  def price_per_rental(rental)
    price = 0
    case rental.movie.price_code
    when Movie::REGULAR
      price += 2
      price += (rental.days_rented - 2) * 1.5 if rental.days_rented > 2
    when Movie::NEW_RELEASE
      price += 1.5
      price += (rental.days_rented - 3) * 1.5 if rental.days_rented > 3
    end
    price
  end

  def add_frequent_renter_points(rental)
    frequent_renter_points = 1
    # add bonus for a two day new release rental
    if rental.movie.price_code == Movie::NEW_RELEASE && rental.days_rented > 1
      frequent_renter_points += 1
    end
    frequent_renter_points
  end
end
