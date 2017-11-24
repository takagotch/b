#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class Connector

  attr_accessor :handler

  def initialize(handler)
    @handler = handler
  end

  def handle_request(uri)
    @handler.handle_request(uri)
  end

end

class ConnectorNoMock

  attr_accessor :handler

  def initialize()
    @handler = HandlerNoMock.new
  end

  def handle_request(uri)
    @handler.handle_request(uri)
  end

end