#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class ConnectionHandler

  attr_accessor :is_connected
  attr_accessor :client

  def initialize(client)
    @client = client
  end

  def receive(message)

    if is_challenge(message)
      @client.send_authenticate_message
      @is_connected = false
    elsif is_welcome(message)
      @is_connected = true
    end

  end

  def is_challenge(message)
    message[:type] == 'challenge'
  end

  def is_welcome(message)
    message[:type] == 'welcome'
  end

end
