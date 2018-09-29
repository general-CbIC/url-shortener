# frozen_string_literal: true

require 'em-hiredis'
require 'sinatra/base'
require 'thin'
require 'json'

def random_string(n)
  symbols = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
  (0...n).map { symbols[rand(symbols.length)] }.join
end

class URLShortener < Sinatra::Base
  def redis
    @redis ||= EM::Hiredis.connect
  end

  post '/' do
    long_url = JSON.parse(request.body.read)['longUrl']
    short_id = random_string(8)
    redis.set short_id, long_url
    JSON.generate(url: "http://localhost:1234/#{short_id}")
  end

  get '*' do
    stream :keep_open do |out|
      s = params['splat'][0]
      short_id = s.slice(1, s.length)

      redis.get(short_id).callback do |long_url|
        if long_url.nil?
          out << 'not_found'
          out.close
        else
          # status 301
          # response.headers['Location'] = long_url
          # header "Location: #{long_url}"
          out.close
          redirect long_url
        end
        # out.close
      end
    end
  end
end

EM.run do
  dispatch = Rack::Builder.app do
    map '/' do
      run URLShortener.new
    end
  end

  Rack::Server.start(
    app: dispatch,
    server: 'thin',
    Host: 'localhost',
    Port: 1234,
    signals: false
  )
end
