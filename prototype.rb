require_relative 'env_init' if File.exist?('env_init.rb')

require 'evernote_oauth'
require 'pry'

init_code = <<-RUBY
MAX_NOTES_PER_QUERY = Evernote::EDAM::Limits::EDAM_RELATED_MAX_NOTES

client = EvernoteOAuth::Client.new(
  token: ENV['OAUTH_TOKEN']
)
note_store = client.note_store(note_store_url: ENV['NOTE_STORE_URL'])

note_filter = Evernote::EDAM::NoteStore::NoteFilter.new(notebookGuid: ENV['COLLECTION_NOTEBOOK_GUID'])
offset = 0
notes = []
until notes.count == (query = note_store.findNotes(ENV['OAUTH_TOKEN'], note_filter, offset, MAX_NOTES_PER_QUERY)).totalNotes
  notes += query.notes
  offset += MAX_NOTES_PER_QUERY
end
RUBY

puts init_code
eval init_code

binding.pry

