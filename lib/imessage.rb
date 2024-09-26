class IMessage
  attr_reader :source, :destinations

  def initialize(params)
    @destinations = Array(params[:destinations])

    puts "iMessage notifications will be sent to the following:"
    destinations.each { |d| puts "- #{d}" }
  end

  def send(msg)
    destinations.all? do |destination|
      cmd = "tell application \"Messages\" to send \"#{msg}\" to participant \"#{destination}\" of account id (id of 1st account whose service type = iMessage)"
      `osascript -e '#{cmd}'`
    end
  end
end
