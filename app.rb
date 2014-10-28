set :cache, Dalli::Client.new

get '/' do
  notebook = Notebook.collection_notebook
  @page_title = @notebook_name = notebook.name
  @notes = notebook.notes
  erb :index
end
