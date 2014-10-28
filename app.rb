set :cache, Dalli::Client.new

get '/' do
  Notebook.collection_notebook.name
end
