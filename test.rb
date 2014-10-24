#
# A simple Evernote API demo script that lists all notebooks in the user's
# account and creates a simple test note in the default notebook.
#
# Before running this sample, you must:
# - fill in your Evernote developer token.
# - install evernote-thrift gem.
#
# To run (Unix):
#   ruby EDAMTest.rb
#

require "digest/md5"
require 'evernote-thrift'
require 'pry'

# Real applications authenticate with Evernote using OAuth, but for the
# purpose of exploring the API, you can get a developer token that allows
# you to access your own Evernote account. To get a developer token, visit
# https://sandbox.evernote.com/api/DeveloperToken.action
authToken = "2fd037fd107b7c9d"


# Initial development is performed on our sandbox server. To use the production
# service, change "sandbox.evernote.com" to "www.evernote.com" and replace your
# developer token above with a token from
# https://www.evernote.com/api/DeveloperToken.action
evernoteHost = "www.evernote.com"
userStoreUrl = "https://#{evernoteHost}/edam/user"

userStoreTransport = Thrift::HTTPClientTransport.new(userStoreUrl)
userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
userStore = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)

versionOK = userStore.checkVersion("Evernote EDAMTest (Ruby)",
           Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
           Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
puts "Is my Evernote API version up to date?  #{versionOK}"
puts
exit(1) unless versionOK

binding.pry

# Get the URL used to interact with the contents of the user's account
# When your application authenticates using OAuth, the NoteStore URL will
# be returned along with the auth token in the final OAuth request.
# In that case, you don't need to make this call.
noteStoreUrl = userStore.getNoteStoreUrl(authToken)

noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

# List all of the notebooks in the user's account
notebooks = noteStore.listNotebooks(authToken)
puts "Found #{notebooks.size} notebooks:"
defaultNotebook = notebooks.first
notebooks.each do |notebook|
  puts "  * #{notebook.name}"
end