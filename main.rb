require 'filewatcher'

Dir[File.join(%w[lib ** *.rb])].each { |f| require_relative f }

PARAMS_FILE = 'params.yml'.freeze

monitor = ProductMonitor.start(PARAMS_FILE)
Filewatcher.new([PARAMS_FILE]).watch do |changes|
  changes.each do |filename, _event|
    puts "\nParameters file has changed. Restarting...\n"
    monitor.kill
    monitor = ProductMonitor.start(filename)
  end
end
