#---
# Excerpted from "Programming Sound with Pure Data",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
#---
require 'rubygems'
require 'sinatra'

get "/" do
  send_file "public/index.html", :type => 'text/html', :disposition => 'inline'
end

