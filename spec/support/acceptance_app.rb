require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

get '/style-guide' do
  haml :style_guide
end
