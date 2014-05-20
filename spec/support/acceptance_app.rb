require 'sinatra'
require 'haml'

class AcceptanceApp < Sinatra::Base
  get '/' do
    haml :index
  end

  get '/style-guide' do
    haml :style_guide
  end
end
