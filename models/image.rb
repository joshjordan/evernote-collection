class Image < Hashie::Mash
  include CachedRepository

  PROPORTIONAL = 0
  SIZES = {
    full:  { width: PROPORTIONAL, height: 400 },
    thumb: { width: 125, height: PROPORTIONAL }
  }

  def self.find(guid)
    new(cache.get(cache_key(guid)) || NoteStore.new.resource(guid).tap do |api_result|
      data = StringIO.new api_result.delete(:raw_data)
      SIZES.each do |size, dimensions|
        data.rewind
        api_result[size] = File.read FastImage.resize(data, dimensions[:width], dimensions[:height])
      end
      cache.set(cache_key(guid), api_result)
    end)
  end

  def self.cache_key(guid)
    ['resource', guid].join(':')
  end
end
