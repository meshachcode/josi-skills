# Description:
#   The process class handles taking a 'task' 
#     - a Task is a set of steps, each of which will include exec, echo, and expect
#
# Dependencies:
#   ./promises
#   ./tasks
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

class Process
  constructor: () ->
    @

  init: (task, robot, msg) ->
    try
      promise = new RSVP.Promise()
      # Do all the work...
      @step(task, msg)
      .done (result) ->
        promise.resolve result
      .fail (error) ->
        promise.reject error
      return promise
    catch e
      e.locale = "Process.init()"
      throw e

  step: (task, msg) ->
    try
      promise = new RSVP.Promise()
      # Start the task!
      msg.robot.skills[task.skill].start(task, msg)
      .done (what) ->
        promise.resolve { task: task, result: what }
        if what.done
          robot.brain.tasks.remove(key)
      .fail (why) ->
        promise.reject why
      return promise
    catch e
      e.locale = "Process.step()"
      throw e

module.exports = Process