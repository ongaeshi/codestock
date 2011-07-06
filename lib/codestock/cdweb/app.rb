# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/06/25

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

$LOAD_PATH.unshift '../..'
require 'codestock/cdweb/lib/database'
require 'codestock/cdweb/lib/coderay_wrapper'
require 'codestock/cdweb/lib/searcher'

set :haml, :format => :html5

helpers do
  alias h escape_html

  def link(keyword)
    "<a href='#{'/::search' + '/' + h(keyword)}'>#{keyword}</a>"
  end

  def view(record, before)
    @title = @path = record.shortpath
    @record_content = CodeRayWrapper.html_memfile(record.content, record.shortpath)
    @elapsed = Time.now - before
    haml :view
  end
end

get '/' do
  @version = '0.1.2'
  @package_num = Database.instance.fileList('').size
  @file_num = Database.instance.fileNum
  haml :index
end

get '/home*' do |path|
  before = Time.now
  path = path.sub(/^\//, "")
  record = Database.instance.record(path)

  if (record)
    view(record, before)
  else
    fileList = Database.instance.fileList(path)
    @keyword = path
    @total_records = fileList.size
    @record_content = '<pre>' + fileList.inspect + '</pre>'
    @elapsed = Time.now - before
    haml :home
  end
end

post '/::search' do
  redirect "/::search/#{escape(params[:query])}"
end

get %r{/::search/(.*)} do |keyword|
  before = Time.now

  searcher = Searcher.new(keyword, params[:page].to_i)
  
  @keyword = searcher.keyword
  @total_records = searcher.total_records
  @range = searcher.page_range
  @elapsed = Time.now - before
  @record_content = searcher.html_contents  + searcher.html_pagination;
  haml :search
end

get %r{/::view/(.*)} do |path|
  before = Time.now
  record = Database.instance.record(path)
  view(record, before)
end

get %r{/::help} do
  haml :help
end
