class Note
  include CachedRepository

  def self.find_all(*guids)
    cached_versions = cache.get_multi(guids.map { |guid| cache_key(guid)} )
    versions = guids.inject({}) do |memo, guid|
      memo[guid] = cached_versions[cache_key(guid)]
      memo
    end
    versions.map { |guid, version| Metadata.find(guid, version) }
  end

  def self.cache_key(guid)
    ['note', guid].join(':')
  end

  class Metadata < Hashie::Mash
    include CachedRepository

    def self.find(guid, version)
      new(cache.get(cache_key(guid, version)) || NoteStore.new.note(guid).tap do |api_result|
        cache.set(Note.cache_key(guid), api_result[:version])
        cache.set(cache_key(guid, api_result.delete(:version)), api_result)
      end)
    end

    def self.cache_key(guid, version)
      ['note-metadata', guid, version].join(':')
    end
  end
end
