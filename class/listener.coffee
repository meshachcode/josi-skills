# Description:
#   None
# 
# Dependencies:
#   None
# 
# Configuration:
#   None
#
# Commands:
#   None
# 
# Author:
#   meshachjackson

RSVP = require '../class/promises'

class Listener
  constructor: (@robot, @expectation) ->
    @

  matcher: (message) =>
    if message.text?
      message.text.match @robotNameRegExp && message.text.match @expectation

  init: () ->
    try
      @promise = new RSVP.Promise()
      if @robot.enableSlash
        @robotNameRegExp = new RegExp("^(?:\/|#{@robot.name}:?)\\s*(.*?)\\s*$", 'i')
      else
        @robotNameRegExp = new RegExp("^#{@robot.name}:?\\s*(.*?)\\s*$", 'i')
      return @promise
    catch e
      throw new Error "Could not init Listener.", e

  call: (message) =>
    try
      match = @matcher message
      if match == null
        @promise.reject message
      else
        @promise.resolve message
    catch e
      throw new Error "Could not call Listener.", e

module.exports = Listener