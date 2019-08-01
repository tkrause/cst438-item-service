require 'httparty'

class ItemClient

  include HTTParty

  # default_options.update(verify: false)
  base_uri "http://localhost:8080"
  headers 'Content-Type' => 'application/json'
  format :json

  def ItemClient.create(params)
    post '/items', body: params.to_json
  end

  def ItemClient.update(params)
    put '/items/' + params[:id], body: params.to_json
  end

  def ItemClient.retrieve(params)
    if params[:id] == 'all'
      get '/items'
    else
      get '/items/' + params[:id], body: params.to_json
    end
  end
end

def get_props(*props)
  data = {}
  props.each do |prop|
    puts "Enter item #{prop}"
    data[prop.to_sym] = gets.chomp
  end

  data
end

def puts_response(response)
  puts "status code #{response.code}"
  puts response.body
end

loop do
  puts 'What do you want to do: create, update, get, get_all or quit'
  choice = gets.chomp.downcase

  case choice
  when 'create'
    props = get_props :description, :price, :stockQty

    puts_response ItemClient.create props
  when 'update'
    props = get_props :id, :description, :price, :stockQty

    puts_response ItemClient.update props
  when 'get'
    props = get_props :id

    puts_response ItemClient.retrieve props
  when 'get_all'
    puts_response ItemClient.retrieve id: 'all'
  when 'quit'
    exit
  else
    puts "Unknown option #{choice}"
  end

  puts
end