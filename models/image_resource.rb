class ImageResource < Hashie::Mash
  include CachedRepository

  PROPORTIONAL = nil
  SIZES = {
    full:  { width: PROPORTIONAL, height: 400 },
    thumb: { width: 125, height: PROPORTIONAL }
  }

  def self.find(guid)
    new(cache.get(cache_key(guid)) || NoteStore.new.resource(guid).tap do |api_result|
      data = api_result.delete(:raw_data)
      SIZES.each do |size, dimensions|
        api_result[size] = MiniMagick::Image.read(data).tap do |image|
          image.resize "#{dimensions[:width]}x#{dimensions[:height]}"
        end.to_blob
      end
      cache.set(cache_key(guid), api_result)
    end)
  end

  def self.cache_key(guid)
    ['resource', guid].join(':')
  end
end
