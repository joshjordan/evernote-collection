class NoteStore
  def initialize(oauth_token: nil, note_store_url: nil)
    @oauth_token = oauth_token || ENV['OAUTH_TOKEN']
    @note_store_url = note_store_url || ENV['NOTE_STORE_URL']
  end

  def notebook(guid)
    notebook = client.getNotebook(@oauth_token, guid)
    { guid: notebook.guid, version: notebook.updateSequenceNum, name: notebook.name, note_guids: NotebookNotesQuery.new(self, guid).to_a }
  end

  def note(guid)
    note = client.getNote(@oauth_token, guid, true, false, false, false)
    { guid: note.guid, version: note.updateSequenceNum, title: note.title, content: note.content, resources: note.resources.map { |r| { guid: r.guid, content_type: r.mime } } }
  end

  def resource(guid)
    client.getResource(@oauth_token, guid, true, false, true, false)
  end

  attr_reader :oauth_token

  def client
    @client ||= oauth_client.note_store note_store_url: @note_store_url
  end

  private

  def oauth_client
    @oauth_client ||= EvernoteOAuth::Client.new token: oauth_token
  end

  class NotebookNotesQuery
    def initialize(note_store, notebook_guid)
      @note_store, @notebook_guid = note_store, notebook_guid
    end

    def to_a
      notes.map(&:guid)
    end

    private

    MAX_NOTES_PER_QUERY = Evernote::EDAM::Limits::EDAM_RELATED_MAX_NOTES

    def notes
      @notes ||= [].tap do |notes|
        until @last_query && notes.count == @last_query.totalNotes
          notes.push *next_query.notes
        end
      end
    end

    def next_query
      @last_query = @note_store.client.findNotesMetadata(
        @note_store.oauth_token,
        note_filter,
        offset.next.to_i,
        MAX_NOTES_PER_QUERY,
        note_result_spec
      )
    end

    def note_filter
      Evernote::EDAM::NoteStore::NoteFilter.new(notebookGuid: @notebook_guid)
    end

    def offset
      @offset ||= (0..Float::INFINITY).step(MAX_NOTES_PER_QUERY)
    end

    def note_result_spec
      Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    end
  end
end
