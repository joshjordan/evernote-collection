require_relative 'dev' if ENV['RACK_ENV'] != 'production'

set :cache, Dalli::Client.new(
  (ENV['MEMCACHIER_SERVERS'] || 'localhost').split(','),
  username: ENV['MEMCACHIER_USERNAME'],
  password: ENV['MEMCACHIER_PASSWORD'],
  failover: true,
  socket_timeout: 1.5,
  socket_failure_delay: 0.2
)

get '/' do
  notebook = Notebook.collection_notebook
  @page_title = @notebook_name = notebook.name
  @notes = notebook.notes
  erb :index
end

SIZES = { 'items' => :full, 'thumbs' => :thumb }

get %r{/(items|thumbs)/(.*)} do |type, guid|
  image = ImageResource.find(guid)

  content_type image.content_type
  image[SIZES[type]]
end
