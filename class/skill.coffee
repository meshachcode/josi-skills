# Description:
#   The Skill class is the shell for allowing future skills to be developed. 
#   Example Skills:
#     - Telling jokes, checking email, complex calculations, 
#       generating complex reporting, filtering through actionable data, etc...
#
# Dependencies:
#   ./promises
#
# Configuration:
#   None
#
# Commands:
#   None
# 
# Author:
#   meshachjackson

RSVP = require './promises'
TextMessage = require('hubot').TextMessage

# The Skill Class...
class Skill
  backFlag: 'back'
  killFlag: 'kill'

  constructor: (@namespace, robot) ->
    robot.logger.info 'New Skill!', @namespace
    @

  # this should be overridden by any extending classes
  # calls converse bby default
  start: (task, msg) ->
    try
      @converse(task, msg)
    catch e
      e.locale = "Skill.start()"
      throw e

  # TODO: Refactor this method...
  # reveal the converse method as the first skills
  converse: (task, msg) ->
    try
      # register the promise
      promise = new RSVP.Promise()
      # handle this transaction
      @thisTime task, msg
      # prepare for the next transaction
      @nextTime task, msg, promise
      # return the promise
      return promise
    catch e
      e.locale = "Skill.converse()"
      throw e

  # TODO: make this an extension of robot.Response
  # robot.Response.prototype.batch = 
  #   some function to handle 'batches' of commands...
  thisTime: (task, msg) ->
    try
      current = task.steps[task.step]
      # what should i say?
      if echo = current.echo
        @echo echo, msg
      # what should i do?
      if exec = current.exec
        @exec exec, msg
    catch e
      e.locale = "Skill.thisTime()"
      throw e

  nextTime: (task, msg, promise) ->
    try
      current = task.steps[task.step]

      # should i prepare to go back?
      # a simple solution for back buttons...
      if task.step == @backFlag
        task.step = task.cache

      # should i kill the process?
      # if the current step has a 'kill' flag
      task[@killFlag] = task.step[@killFlag] or false
      if task[@killFlag]
        # don't run the expect, politely resolve the promise.
        promise.resolve msg.message
        return

      # do i expect a reply?
      # if the current step is not expecting...
      if !current.expect?.pass?
        delete current.expect
      else
        # establish the fail step
        current.expect.fail = current.expect.fail or 'fail'
        msg.chatty "c: #{task.step}, p: #{current.expect.pass}, f: #{current.expect.fail}"
      if expect = current.expect
        @expect expect, msg, promise, task
      else
        if current.step == 'fail'
          promise.reject msg.message
        else
          promise.resolve msg.message
    catch e
      e.locale = "Skill.nextTime()"
      throw e

  expect: (hear, msg, promise, task) ->
    try
      self = @
      e = new RegExp(hear.respond.toString(), 'i')
      msg.chatty "(expecting... #{e})"
      # expect() handles the validation...
      msg.expect(e)
      .done (message) ->
        self.pass task, msg, message, promise
      .fail (message) ->
        self.fail task, msg, message, promise
    catch e
      e.locale = "Skill.expect()"
      throw e

  pass: (task, msg, message, promise) ->
    try
      task.last = task.step
      task.step = task.steps[task.step].expect.pass
      @converse task, msg      
    catch e
      e.locale = "Skill.pass()"
      throw e

  fail: (task, msg, message, promise) ->
    try
      # predict if the next step will need the option of coming back (2nd Chances...)
      failstep = task.steps[task.step].expect.fail
      if task.steps[failstep].expect.pass == @backFlag
        task.cache = task.step

      # accept the command if it failed because of 'back'
      if /back/i.test(message.text)
        @back task, msg
      else 
        # try to fail gracefully and according to script...
        if task.step = failstep
          msg.robot.logger.info "going again!"
          @converse task, msg
        else
          msg.robot.logger.info "done!"
          promise.reject message
    catch e
      e.locale = "Skill.fail()"
      throw e

  back: (task, msg) ->
    try
      task.step = task.last
      @converse task, msg
    catch e
      e.locale = "Skill.back()"
      throw e

# Say, Speak, Tell, Talk, Echo, Express
  echo: (say, msg) ->
    try
      promise = new RSVP.Promise()
      if say && msg
        msg.send say
        promise.resolve msg.message
      else
        promise.reject msg.message
      return promise
    catch e
      e.locale = "Skill.echo()"
      throw e

# Execute, Exec, Do
  exec: (heard, msg) ->
    try
      promise = new RSVP.Promise()
      if tm = new TextMessage(msg.message.user, "#{msg.robot.name}: #{heard}")
        msg.robot.receive tm
        promise.resolve msg.message
      else
        promise.reject msg.message
      return promise
    catch e
      e.locale = "Skill.exec()"
      throw e

module.exports = Skill