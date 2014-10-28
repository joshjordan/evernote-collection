class Notebook
  include CachedRepository

  def self.find(guid)
    version = cache.get(cache_key(guid))
    Metadata.find(guid, version)
  end

  def self.collection_notebook
    find ENV['COLLECTION_NOTEBOOK_GUID']
  end

  def self.cache_key(guid)
    ['notebook', guid].join(':')
  end

  private

  class Metadata < Hashie::Mash
    include CachedRepository

    def self.find(guid, version)
      new(cache.get(cache_key(guid, version)) || NoteStore.new.notebook(guid).tap do |api_result|
        cache.set(Notebook.cache_key(guid), api_result[:version])
        cache.set(cache_key(guid, api_result.delete(:version)), api_result)
      end)
    end

    def self.cache_key(guid, version)
      ['notebook-metadata', guid, version].join(':')
    end

    def notes
      @notes ||= Note.find_all(*note_guids)
    end
  end
end
