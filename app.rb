# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"
require "securerandom"

before do
  params[:id] == nil ? @id = SecureRandom.hex(10) : @id = params[:id]
  params[:title] == "" ? @title = "non title" : @title = params[:title]
  @body = params[:body]
  @hush = { id: @id, title: @title, body: @body }
end

def write_memo(id)
  File.open("memos/#{id}.json", "w") { |file| JSON.dump(@hush, file) }
end

def open_memo(id)
  File.open("memos/#{id}.json") { |file| @memo = JSON.parse(File.read(file), symbolize_names: true) }
end

def delete_memo(id)
  File.delete("memos/#{id}.json")
end

get "/" do
  @json_dir = Dir.glob("memos/*.json").sort_by { |f| File.mtime(f) }.reverse
  erb :index
end

get "/new" do
  erb :new
end

post "/new" do
  write_memo(@id)
  erb :new
  redirect "/"
end

get "/:id" do
  open_memo(params[:id])
  erb :show
end

get "/:id/edit" do
  open_memo(params[:id])
  erb :edit
end

put "/:id/edit" do
  p @title
  write_memo(params[:id])
  redirect "/#{params[:id]}"
end

delete "/:id" do
  delete_memo(params[:id])
  redirect "/"
end
