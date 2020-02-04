# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"
require "securerandom"

before do
  params[:id] == nil ? @id = SecureRandom.hex(10) : @id = params[:id]
  params[:title] == "" ? @title = "non title" : @title = params[:title]
  @body = params[:body]
end

class Memo
  def write(id, title, body)
    hash = { id: id, title: title, body: body }
    File.open("memos/#{id}.json", "w") { |file| JSON.dump(hash, file) }
  end

  def open(id)
    File.open("memos/#{id}.json") { |file| JSON.parse(File.read(file), symbolize_names: true) }
  end

  def delete(id)
    File.delete("memos/#{id}.json")
  end
end

get "/" do
  @json_dir = Dir.glob("memos/*.json").sort_by { |f| File.mtime(f) }.reverse
  erb :index
end

get "/new" do
  erb :new
end

post "/new" do
  Memo.new.write(@id, @title, @body)
  erb :new
  redirect "/"
end

get "/:id" do
  @memo = Memo.new.open(params[:id])
  erb :show
end

get "/:id/edit" do
  @memo = Memo.new.open(params[:id])
  erb :edit
end

put "/:id/edit" do
  Memo.new.write(params[:id], @title, @body)
  redirect "/#{params[:id]}"
end

delete "/:id" do
  Memo.new.delete(params[:id])
  redirect "/"
end
