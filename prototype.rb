puts File.read(__FILE__)

require_relative 'env_init' if File.exist?('env_init.rb')

require 'evernote_oauth'
require 'pry'
require 'dalli'

# Get token and note store URL from https://www.evernote.com/api/DeveloperToken.action

MAX_NOTES_PER_QUERY = Evernote::EDAM::Limits::EDAM_RELATED_MAX_NOTES

cache = Dalli::Client.new('localhost:11211', { compress: true })
client = EvernoteOAuth::Client.new(
  token: ENV['OAUTH_TOKEN']
)
note_store = client.note_store(note_store_url: ENV['NOTE_STORE_URL'])

# implemented up to here

note_filter = Evernote::EDAM::NoteStore::NoteFilter.new(notebookGuid: ENV['COLLECTION_NOTEBOOK_GUID'])
offset = 0
result_spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new(includeUpdated: true)
note_results = []
puts "Fetching note metadata from notebook..."
until note_results.count == (query = note_store.findNotesMetadata(ENV['OAUTH_TOKEN'], note_filter, offset, MAX_NOTES_PER_QUERY, result_spec)).totalNotes
  note_results += query.notes
  offset += MAX_NOTES_PER_QUERY
end

note_data = []
note_results.each do |result|
  note_cache_key = ['note', result.guid, result.updated].join(':')
  puts
  puts "Checking cache for note #{result.guid}..."
  note_data << (cache.get(note_cache_key) || begin
    puts "Cache miss. Fetching note #{result.guid}..."
    note = note_store.getNote(ENV['OAUTH_TOKEN'], result.guid,
      true, #include content
      false, #include resource binary data
      false,
      false
    )
    puts note.title
    {
      guid: note.guid,
      title: note.title,
      content: note.content,
      resources: note.resources.collect do |r|
        { guid: r.guid, content_type: r.mime }
      end
    }.tap do |obj|
      puts "Caching #{obj}"
      cache.set(note_cache_key, obj)
    end
  end)
end

binding.pry
