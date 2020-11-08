require "awesome_print"
require "cgi"
require "httparty"

# This is specific to the voip.ms api
class SMSClient
  URL = "https://voip.ms/api/v1/rest.php"
  MAX_LEN = 160 - 1

  attr_reader :source, :destinations

  def initialize(params)
    @api_username = params[:api_username]
    @api_password = params[:api_password]
    @source = params[:source]
    @destinations = Array(params[:destinations])
  end

  # Returns true if the message was sent successfully to everyone
  def send(message)
    destinations.all? do |destination|
      params = {
        api_username: api_username,
        api_password: api_password,
        method: :sendSMS,
        did: source,
        dst: destination,
        message: CGI.escape(message)[0..MAX_LEN]
      }.map { |p| p.join("=") }
      url = "#{URL}?#{params.join('&')}"

      response = HTTParty.get(url, headers: { "content-type" => "application/json" })
      status = JSON.parse(response&.body).dig("status")
      success = response.success? && status == "success"
      puts "😨 Unable to send message to #{destination}. Status: #{status}" unless success
      success
    end
  end

  private

  attr_reader :api_username, :api_password
end
