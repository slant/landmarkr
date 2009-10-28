$:.unshift File.dirname(__FILE__) + '/sinatra/lib'
require 'rubygems'
require 'sinatra'
gem 'dm-core'
require 'dm-core'
require 'Haml'


# Configuration
use Rack::Session::Pool
  
configure do
  DataMapper.setup(:default, "sqlite3:///#{File.dirname(File.expand_path(__FILE__))}/db/landmarkr.sqlite3")
  DataMapper.auto_upgrade!
end



# Routes

get "/" do
  # description of service and SLURL to purchase landmarkr
  @agents = Agent.all
  @agent_landmarks = Agent.get(1).landmarks
  @landmarks = Landmark.all
  haml :index
end

post "/register" do
  agent = Agent.new(:name => params[:name], :key => params[:key])
  agent.save
end

get "/landmarks" do
  agent = Agent.new(:name => "My Name", :key => "1234")
  agent.save

  @agent = Agent.get(1)

  landmark = Landmark.new(
    :name => "A Place",
    :region => "Anala",
    :x => 1,
    :y => 2,
    :z => 3,
    :created_at => Time.now,
    :agent_id => @agent.id )
  landmark.save

  redirect "/"
end

get "/landmarks/:agent_id" do
  # object in SL will check username against web app.
  # if username exists, it will offer to take the user
  # to their page. otherwise, will offer registration.
  #
  # agent name will be unique identifier
  # check to see if user exists
  # show landmarks
  if @agent = Agent.get(params[:agent_id])
    @landmarks = @agent.landmarks(:order => [:created_at.asc])
  end

  haml :landmarks
end

get "/test" do
  builder do |xml|
    xml.instruct! :xml, :version => '1.1'
      
    end

    xml.instruct! :xml, :version => '1.1'
    xml.person do
      xml.name "Francis Albert Sinatra"
      xml.aka "Frank Sinatra"
      xml.aka "Ol' Blue Eyes"
      xml.aka "The Chairman of the Board"
      xml.born 'date' => '1915-12-12' do
        xml.text! "Hoboken, New Jersey, U.S.A."
      end
      xml.died 'age' => 82
    end
  end
end

get "/test.xml" do
  content_type 'text/html', :charset => 'utf-8'
  ""
end

post "/landmarks" do
    landmark = Landmark.new(
      :name => params[:name],
      :region => params[:region],
      :x => params[:x],
      :y => params[:y],
      :z => params[:z],
      :created_at => Time.now,
      :agent_id => @agent.id ).save
end

post "/user_exists/:agent_key" do
  if Agent.first(:key => params[:agent_key])
    "true"
  else
    "false"
  end
  "test"
end

not_found do
  redirect "/"
end



# Helpers

helpers do
  def formatted_landmark(location)
    "<p><strong>#{location.name}</strong> #{location.region} (#{location.x}, #{location.y}, #{location.z})</p>"
  end
  
  def slurl(location)
    "http://slurl.com/secondlife/#{location.region}/#{location.x}/#{location.y}/#{location.z}/?title=#{location.name}&msg=#{location.description}"
  end
  
  def sllink(location)
    return "secondlife://#{location.region}/#{location.x}/#{location.y}/#{location.z}"
  end
end



# Models

class Agent
  include DataMapper::Resource
  property :id,    Integer, :serial => true
  property :name,  String
  property :key,   String

  has n, :landmarks
end

Agent.auto_upgrade!

class Landmark
  include DataMapper::Resource
  property :id,         Integer, :serial => true
  property :name,       String
  property :region,     String
  property :x,          Integer
  property :y,          Integer
  property :z,          Integer
  property :created_at, DateTime
  property :agent_id,   Integer

  belongs_to :agent
end

Landmark.auto_upgrade!