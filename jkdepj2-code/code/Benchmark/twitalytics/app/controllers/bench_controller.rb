#---
# Excerpted from "Deploying with JRuby 9k",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jkdepj2 for more book information.
#---
class BenchController < ApplicationController
  def index
    history = session[:history] || []
    history.shift if history.size > params[:save].to_i
    history << (1..100).map { rand(1 << 256) + rand(1 << 256) }
    session[:history] = history

    render :text => "done"
  end
end
