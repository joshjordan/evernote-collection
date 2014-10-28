set :cache, Dalli::Client.new

get '/' do
  notebook = Notebook.collection_notebook
  @page_title = @notebook_name = notebook.name
  @notes = notebook.notes
  erb :index
end

get %r{/items/(.*)} do |resource_guid|
  data = settings.cache.get("resource:#{resource_guid}")
  if !data
    resource = NoteStore.new.resource(resource_guid)
    resized = FastImage.resize(StringIO.new(resource.data.body), 0, 400)
    data = File.read(resized)
    settings.cache.set("resource:#{resource_guid}", data)
  end

  content_type 'image/jpeg'
  data
end

get %r{/thumbs/(.*)} do |resource_guid|
  data = settings.cache.get("resource-thumb:#{resource_guid}")
  if !data
    resource = NoteStore.new.resource(resource_guid)
    resized = FastImage.resize(StringIO.new(resource.data.body), 125, 0)
    data = File.read(resized)
    settings.cache.set("resource-thumb:#{resource_guid}", data)
  end

  content_type 'image/jpeg'
  data
end

get '/console' do
  binding.pry
end
