set :cache, Dalli::Client.new

get '/' do
  notebook = Notebook.collection_notebook
  @page_title = @notebook_name = notebook.name
  @notes = notebook.notes
  erb :index
end

get %r{/items/(.*)} do |resource_guid|
  resource = NoteStore.new.resource(resource_guid)
  content_type resource.mime
  resource.data.body
end
