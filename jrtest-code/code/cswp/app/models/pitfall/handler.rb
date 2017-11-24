#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class Handler

  attr_accessor :transport

  def initialize(transport)
    @transport = transport
  end

  def handle_request(uri)
    @transport.send(uri)
  end

end

class HandlerNoMock

  attr_accessor :transport

  def initialize()
    @transport = Transport.new
  end

  def handle_request(uri)
    @transport.send(uri)
  end

end