$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'refactoring_ruby_edition'
require 'rspec/expectations'

RSpec::Matchers.define :match_text_report do |report_data|
  match do |actual|
    actual == report_string(report_data)
  end
  description do
    "\nto be equal to\n         #{report_string(report_data).inspect}"
  end

  def report_string(data)
    expected_text = ''
    expected_text += "Rental Record for #{data.name}\n"
    data.movies.each do |movie|
      expected_text += "\t" + movie[:title] + "\t" + movie[:amount].to_s + "\n"
    end
    expected_text += "Amount owed is #{data.total}\n"
    expected_text += "You earned #{data.frequent_renter_points} frequent renter points"
    expected_text
  end
end

class ReportData
  attr_accessor :frequent_renter_points, :total, :movies, :name
  def initialize(name)
    @name = name
    @movies = []
    @points = 0
  end

  def add_movie(title, amount)
    @movies << { title: title, amount: amount }
  end
end
