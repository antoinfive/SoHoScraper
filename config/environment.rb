require 'bundler/setup'
Bundler.require(:default, :development)
$: << '.'

Dir["app/concerns/*.rb"].each {|f| require f}
Dir["app/models/*.rb"].each {|f| require f}
Dir["app/data_fetcher/*.rb"].each {|f| require f}
Dir["app/runners/*.rb"].each {|f| require f}

require "open-uri"
require "json"
require "net/http"
