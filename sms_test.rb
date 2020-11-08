require "byebug"
require_relative "hash"
require_relative "sms_client"

params = YAML.safe_load(File.read("params.yml")).symbolize_keys
sms_params = params[:sms].symbolize_keys

sms = SMSClient.new(sms_params)
sms.send("🎉🎉🎉 test 🎉🎉🎉")
