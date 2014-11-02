set :cache, Dalli::Client.new

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
