require 'bundler/setup'
require 'em-twitter'

EM::run do

  options = {
    :path   => '/1/statuses/filter.json',
    :params => {
      :track            => 'akeythatonlyiuse'
    },
    :oauth  => {
      :consumer_key     => 'PRmfDxBU811OYZeuf3tLAQ',
      :consumer_secret  => '5xHUTGtTKZ7zTuch7Pj3EyUIUmaVonpXjvHp5wNmr1Y',
      :token            => '1089024607-I5HwsqvUCotisatNUx3qgdZMLRc26fy4J7pIHTA',
      :token_secret     => 'RkbrOoHACe9RVbyhBpEq0JnC9YN68ZB11428N5Ya74',
    }
  }

  client = EM::Twitter::Client.connect(options)

  client.each do |result|
    puts result
  end

  client.on_error do |message|
    puts "oops: error: #{message}"
  end

  client.on_unauthorized do
    puts "oops: unauthorized"
  end

  client.on_forbidden do
    puts "oops: unauthorized"
  end

  client.on_not_found do
    puts "oops: not_found"
  end

  client.on_not_acceptable do
    puts "oops: not_acceptable"
  end

  client.on_too_long do
    puts "oops: too_long"
  end

  client.on_range_unacceptable do
    puts "oops: range_unacceptable"
  end

  client.on_enhance_your_calm do
    puts "oops: enhance_your_calm"
  end

  EM.add_periodic_timer(5, proc { puts "Still connected..." })


  stop = proc { puts "Terminating EM"; EM.stop }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

end
