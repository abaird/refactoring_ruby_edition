require 'spec_helper'

describe 'Video Store App' do
  it 'should have a Movie class' do
    movie = Movie.new('LOTR', 1234)
    expect(movie.title).to eq('LOTR')
  end
end
