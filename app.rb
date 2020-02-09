# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"
require "securerandom"

before do
  @id = SecureRandom.hex(10)
  @title = params[:title]
  @title = "non title" if @title == ""
  @body = params[:body]
end

class Memo
  def self.write(id: id, title: title, body: body)
    hash = { id: id, title: title, body: body }
    File.open("memos/#{id}.json", "w") { |file| JSON.dump(hash, file) }
  end

  def self.find(id)
    File.open("memos/#{id}.json") { |file| JSON.parse(file.read, symbolize_names: true) }
  end

  def delete(id)
    File.delete("memos/#{id}.json")
  end
end

get "/" do
  @json_dir = Dir.glob("memos/*.json").sort_by { |file| File.mtime(file) }.reverse
  erb :index
end

get "/new" do
  erb :new
end

post "/new" do
  Memo.write(id: @id, title: @title, body: @body)
  erb :new
  redirect "/"
end

get "/:id" do
  @memo = Memo.find(params[:id])
  erb :show
end

get "/:id/edit" do
  @memo = Memo.find(params[:id])
  erb :edit
end

put "/:id/edit" do
  Memo.write(id: params[:id], title: @title, body: @body)
  redirect "/#{params[:id]}"
end

delete "/:id" do
  Memo.new.delete(params[:id])
  redirect "/"
end
