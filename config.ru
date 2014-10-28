require 'rubygems'
require 'bundler'
require_relative 'env_init' if File.exist?('env_init.rb')

Bundler.require(:default, ENV['RACK_ENV'])

require File.expand_path '../app.rb', __FILE__
Dir[File.dirname(__FILE__) + '/models/*.rb'].each { |f| require f }

run Sinatra::Application
