require_relative '../spec_helper.rb'
require 'rack/test'
require 'json'

RSpec.describe 'Server responses' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'adding to the index' do
    def post_with(pid, c)
      post(
        '/index', 
        { pageId: pid, content: c }.to_json,
        'CONTENT_TYPE' => 'application/json',
        'Accept' => 'application/json'
      )
    end

    it 'responds with application/json 204 for well-formed content' do
      post_with(300, 'Elementary, my dear Watson')
      expect(last_response.status).to eq(204)
      expect(last_response.body).to be_empty

      # this currently fails because sinatra seems to enforce
      # the idea that if you have a status code of 204, then you
      # should have no Content-Type (since you send no content)
      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    context 'malformed content' do
      it 'rejects non-numerical pageIds' do
        post_with('abcd', 'Elementary, my dear Watson')
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(400)
        expect(last_response.headers['Content-Type']).to eq('application/json')

        body = JSON.parse(last_response.body)
        expect(body['message']).to eq('pageId must be numeric')
      end

      it 'rejects empty content' do
        post_with(301, '')
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(400)
        expect(last_response.headers['Content-Type']).to eq('application/json')

        body = JSON.parse(last_response.body)
        expect(body['message']).to eq('Provided content is empty')
      end

      it 'rejects content with no word-like text' do
        post_with(302, ' !@#$%^&*()_+[]{}')
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(400)
        expect(last_response.headers['Content-Type']).to eq('application/json')

        body = JSON.parse(last_response.body)
        expect(body['message']).to eq('Provided content contains no alphanumeric text')
      end
    end
  end

  context 'retrieving from the index' do
    before :each do
      INDEX.dump
      INDEX.insert(300, 'Elementary, my dear Watson')
      INDEX.insert(12, 'My dearest Eleanor')
    end

    it 'responds with application/json 200 for well-formed queries' do
      get "/search?query=#{URI.encode('Elementary, my dear Watson')}"
      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect(last_response).to be_ok

      body = JSON.parse(last_response.body, symbolize_names: true)
      expect(body.size).to eq(2)
      expect(body.first[:pageId]).to eq(300)
      expect(body.first[:score]).to eq(4)
      expect(body.last[:pageId]).to eq(12)
      expect(body.last[:score]).to eq(1)
    end

    it 'rejects query-less requests' do
      get "/search"
      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq(400)
      body = JSON.parse(last_response.body)
      expect(body['message']).to eq('Must provide a `query` param to /search')
    end

    it 'rejects empty queries' do
      get "/search?query=#{URI.encode('')}"

      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq(400)
      body = JSON.parse(last_response.body)
      expect(body['message']).to eq('Provided content is empty')
    end

    it 'rejects queries with no word-like-text' do
      get "/search?query=#{URI.encode(' !@#$%^&*()-=_+[]{}|[];')}"
      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq(400)
      body = JSON.parse(last_response.body)
      expect(body['message']).to eq('Provided content contains no alphanumeric text')
    end
  end
end
