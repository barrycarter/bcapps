#!/bin/ruby

# SOAP server, proof of concept only

def soapserver
  server = SOAP::RPC::StandaloneServer.new('SwAServer', '', '0.0.0.0', 7000)
  server.add_servant(Doubler.new)
  server.start
end

class Doubler
  def double (arg) 2*arg end
end
