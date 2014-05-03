require 'xmlrpc/client'
require 'json'

user = ENV["USER"]
passwd = ENV["PASSWORD"]
app_name = ENV["APP_NAME"]
app_type = ENV["APP_TYPE"] || "custom_app_with_port"

server = XMLRPC::Client.new2('https://api.webfaction.com/')
session_id, account = server.call "login", user, passwd
result = server.call "create_app", session_id, app_name, app_type, false, "", false
puts JSON.generate(result)
