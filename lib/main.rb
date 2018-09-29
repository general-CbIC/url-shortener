# frozen_string_literal: true

module Main
  require 'em-hiredis'
  require 'sinatra/async'
  require 'thin'
  require 'json'

  def random_string(n)
    symbols = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    (0...n).map { symbols[rand(symbols.length)] }.join
  end

  class URLShortener < Sinatra::Base
    register Sinatra::Async

    def redis
      @redis ||= EM::Hiredis.connect
    end

    post '/' do
      long_url = JSON.parse(request.body.read)['longUrl']
      short_id = random_string(8)
      redis.set short_id, long_url
      JSON.generate(url: "http://localhost:1234/#{short_id}")
    end

    aget '*' do
      s = params['splat'][0]
      short_id = s.slice(1, s.length)

      request = redis.get(short_id)

      request.callback do |long_url|
        if long_url.nil?
          body 'not_found'
        else
          status 301
          headers['Location'] = long_url
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
end
