class NoteStore
  def initialize(oauth_token: nil, note_store_url: nil)
    @oauth_token = oauth_token || ENV['OAUTH_TOKEN']
    @note_store_url = note_store_url || ENV['NOTE_STORE_URL']
  end

  def notebook(guid)
    notebook = note_store.getNotebook(@oauth_token, guid)
    { guid: notebook.guid, name: notebook.name }
  end

  private

  def note_store
    @note_store ||= client.note_store note_store_url: @note_store_url
  end

  def client
    @client ||= EvernoteOAuth::Client.new token: @oauth_token
  end
end
