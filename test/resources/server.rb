require 'rubygems'
require 'sinatra/base'

class Hash
  def to_json
    OkJson.encode(self)
  end
end

class ProviderServer < Sinatra::Base
helpers do
  def xplenty_only!
    unless auth_xplenty?
      response['WWW-Authenticate'] = %(Basic realm="Kensa Test Server")
      unauthorized!(401)
    end
  end

  def auth_xplenty?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['myaddon', 'secret']
  end

  def unauthorized!(status=403)
    throw(:halt, [status, "Not authorized\n"])
  end

  def make_token
    Digest::SHA1.hexdigest([params[:id], 'SSO_SALT', params[:timestamp]].join(':'))
  end

  def json_must_include(keys)
    params = OkJson.decode(request.body.read)
    keys.each do |param|
      raise "#{param} not included with request" unless params.keys.include? param
    end
  end
  
  def login(xplenty_user=true)
  @header = xplenty_user
  haml <<-HAML
%html
%body
  - if @header
    #xplenty-header
      %h1 Xplenty
  %h1 Sample Addon
HAML
  end
end

post '/xplenty/resources' do
  xplenty_only!
  { :id => 123 }.to_json
end

post '/working/xplenty/resources' do
  json_must_include(%w{xplenty_id plan callback_url logplex_token options})
  xplenty_only!
  { :id => 123 }.to_json
end

post '/cmd-line-options/xplenty/resources' do
  xplenty_only!
  options = OkJson.decode(request.body.read)['options']
  raise "Where are my options?" unless options['foo'] && options['bar']
  { :id => 123 }.to_json
end

post '/foo/xplenty/resources' do
  xplenty_only!
  'foo'
end

post '/invalid-json/xplenty/resources' do
  xplenty_only!
  'invalidjson'
end

post '/invalid-response/xplenty/resources' do
  xplenty_only!
  'null'
end

post '/invalid-status/xplenty/resources' do
  xplenty_only!
  status 422
  { :id => 123 }.to_json
end

post '/invalid-missing-id/xplenty/resources' do
  xplenty_only!
  { :noid => 123 }.to_json
end

post '/invalid-missing-auth/xplenty/resources' do
  { :id => 123 }.to_json
end


put '/working/xplenty/resources/:id' do
  json_must_include(%w{xplenty_id plan})
  xplenty_only!
  {}.to_json
end

put '/invalid-missing-auth/xplenty/resources/:id' do
  { :id => 123 }.to_json
end

put '/invalid-status/xplenty/resources/:id' do
  xplenty_only!
  status 422
  {}.to_json
end


delete '/working/xplenty/resources/:id' do
  xplenty_only!
  "Ok"
end

def sso
  unauthorized! unless params[:id] && params[:token]
  unauthorized! unless params[:timestamp].to_i > (Time.now-60*2).to_i
  unauthorized! unless params[:token] == make_token
  response.set_cookie('xplenty-nav-data', params['nav-data'])
  login
end

get '/working/xplenty/resources/:id' do
  sso
end

post '/working/sso/login' do
  #puts params.inspect
  sso
end

def notoken
  unauthorized! unless params[:id] && params[:token]
  unauthorized! unless params[:timestamp].to_i > (Time.now-60*2).to_i
  response.set_cookie('xplenty-nav-data', params['nav-data'])
  login
end

get '/notoken/xplenty/resources/:id' do
  notoken
end

post '/notoken/sso/login' do
  notoken
end

def notimestamp
  unauthorized! unless params[:id] && params[:token]
  unauthorized! unless params[:token] == make_token
  response.set_cookie('xplenty-nav-data', params['nav-data'])
  login
end

get '/notimestamp/xplenty/resources/:id' do
  notimestamp
end

post '/notimestamp/sso/login' do
  notimestamp
end

def nolayout
  unauthorized! unless params[:id] && params[:token]
  unauthorized! unless params[:timestamp].to_i > (Time.now-60*2).to_i
  unauthorized! unless params[:token] == make_token
  response.set_cookie('xplenty-nav-data', params['nav-data'])
  login(false)
end

get '/nolayout/xplenty/resources/:id' do
  nolayout
end

post '/nolayout/sso/login' do
  nolayout
end

def nocookie
  unauthorized! unless params[:id] && params[:token]
  unauthorized! unless params[:timestamp].to_i > (Time.now-60*2).to_i
  unauthorized! unless params[:token] == make_token
  login
end

get '/nocookie/xplenty/resources/:id' do
  nocookie
end

post '/nocookie/sso/login' do
  nocookie
end

def badcookie
  unauthorized! unless params[:id] && params[:token]
  unauthorized! unless params[:timestamp].to_i > (Time.now-60*2).to_i
  unauthorized! unless params[:token] == make_token
  response.set_cookie('xplenty-nav-data', 'wrong value')
  login
end

get '/badcookie/xplenty/resources/:id' do
  badcookie
end

post '/badcookie/sso/login' do
  badcookie
end

def sso_user
  head 404 unless params[:email] == 'username@example.com'
  sso
end

get '/user/xplenty/resources/:id' do
  sso_user
end

post '/user/sso/login' do
  sso_user
end

get '/' do
  unauthorized! unless session[:logged_in]
end

if $0 == __FILE__
 self.run!
end
end
