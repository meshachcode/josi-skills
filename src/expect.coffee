# Description:
#   Adds the ability to handle callbacks on Responses
#   (based heavily on the conversation.coffee script in hubot-scripts by pescuma)
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot test expect - hubot will respond with 'say yes', and expect you to say 'yes'
#
# Author:
#   meshachjackson

Listener = require '../class/listener'
RSVP = require '../class/promises'

module.exports = (robot) ->

  tempCache = {}

  robot.Response.prototype.expect = (valid) ->
    try
      promise = new RSVP.Promise()
      # pass a promise
      robot.addResponse @message.user, valid, promise
      promise      
    catch e
      robot.logger.error e, "expect/expect()"
      @send "I'm sorry. Something went wrong trying to expect."

  robot.addResponse = (user, valid, promise) ->
    try
      # create the listener with the validation rules
      tempCache[user.id] = new Listener(robot, valid)
      # initiate the listener to get it's promise
      tempCache[user.id].init()
      .done (message) ->
        # resolve the promise object sent to us via expect()
        promise.resolve message
      .fail (message) ->
        # resolve the promise object sent to us via expect()
        promise.reject message
    catch e
      robot.logger.error e, "expect/robot.addResponse()"

  # Change default receive command, addind processing of tempCache
  robot.oldReceive = robot.receive
  robot.receive = (message) ->
    try
      # robot.logger.info message, "received message"
      # if there is a message and a matching listener
      if message.user? and tempCache[message.user.id]?
        # robot.logger.info "message found in cache"
        # store the recent listener
        recent = tempCache[message.user.id]
        # remove the reference
        delete tempCache[message.user.id]
        # call the listener
        if recent.call message
          return
        # restore the object to allow the robot to process next message
        tempCache[message.user.id] = recent
      # send the message to the bot
      robot.oldReceive(message)
    catch e
      robot.logger.error e, "expect/robot.receive()"


#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
####################### TESTS!!! #################################
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

   iterate = (nums) ->
    [ nums[1], nums[0] + nums[1] ]

# USAGE EXAMPLE ... very fun.
  robot.respond /test expect$/i, (msg) ->
    msg.send "Say 'yes'"
    try
      msg.expect(/y/i)
        .then (result) ->
          result.count = iterate([0, 1])
          msg.send "Well done! Now I can do this #{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "... and I can still do this! #{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "#{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "#{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "#{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "#{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "#{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "#{result.count[1]}"
          result
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "What number is this? --> [#{result.count[1]}]"
          e = new RegExp result.count[1], 'i'
          msg.expect(e)
          .done (message) ->
            return result
          .fail (message) ->
            msg.send "You did not say what I expected..."
            msg.send "Instead, you said #{message.text}."
            msg.send "...so that will be all for now."
            msg.finish()
        .then (result) ->
          result.count = iterate(result.count)
          msg.send "#{result.count[1]}"
          result
        .done (result) ->
          result.count = iterate(result.count)
          msg.send "... and this! #{result.count[1]}"
          result
        .fail (result) ->
          robot.logger.info result, "Test Expect Failed"
          msg.send "Well, it was worth a shot."
    catch e
      robot.logger.error e
      msg.send "Unfortunately, something has gone very wrong."
