require 'sinatra'
require 'rack/parser'
require 'json'
require 'byebug'
require File.join(File.dirname(__FILE__), 'environment')

use Rack::Parser, :parsers => {
  'application/json' => ->(data) { JSON.parse(data, symbolize_names: true) }
}

def safely
  begin
    yield if block_given?
  rescue EmptyContentsError => e
    [400, { message: e.message }.to_json]
  rescue NoWordsError => e
    [400, { message: e.message }.to_json]
  end
end 

INDEX = HashIndex.new

before('*') { content_type :json }

post '/index' do
  page_id, content = params.values_at(:pageId, :content)

  if page_id.is_a? Numeric
    safely do
      INDEX.insert(page_id, content)
      204
    end
  else
    [400, { message: 'pageId must be numeric' }.to_json]
  end
end

get '/search' do
  query = params['query']

  if query.nil?
    [400, { message: 'Must provide a `query` param to /search' }.to_json]
  else
    safely do
      matches = INDEX.fetch_matches(query)
      [200, { matches: matches }.to_json]
    end
  end
end
