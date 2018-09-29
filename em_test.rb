require 'eventmachine'

EventMachine.run do
  puts "starting EventMachine at #{Time.now}"
  EM.add_timer(2) do
    puts 'Hello world'
    puts "stopping EventMachine at #{Time.now}"
    EM.stop
  end
end