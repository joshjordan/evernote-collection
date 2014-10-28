require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV['RACK_ENV'])


require File.expand_path '../app.rb', __FILE__
run Sinatra::Application
