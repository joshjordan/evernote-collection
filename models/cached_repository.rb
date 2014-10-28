module CachedRepository
  def self.included(base)
    class << base
      def cache
        Sinatra::Application.settings.cache
      end
    end
  end
end
