require_relative '../spec_helper.rb'
require 'rack/test'

RSpec.describe 'Server responses' do
  def app
    Sinatra::Application
  end

  context 'adding to the index' do
    it 'responds with application/json 204 for well-formed content' do
    end

    it 'rejects non-numerical pageIds' do
    end

    context 'malformed content' do
      it 'rejects empty content' do
      end

      it 'rejects content with no word-like text' do
      end
    end
  end

  context 'retrieving from the index' do
    it 'responds with application/json 200 for well-formed queries' do
    end
  end
end
