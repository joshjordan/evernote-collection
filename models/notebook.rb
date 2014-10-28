class Notebook < Hashie::Mash
  include CachedRepository

  def self.find(guid)
    new(cache.get(cache_key(guid)) || NoteStore.new.notebook(guid).tap do |api_result|
      cache.set(cache_key(guid), api_result)
    end)
  end

  def self.collection_notebook
    find ENV['COLLECTION_NOTEBOOK_GUID']
  end

  def self.cache_key(guid)
    ['notebook', guid].join(':')
  end
end
