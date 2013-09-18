# Description:
#   Adds the ability string processes together with a simple
#   adaptation of the Response object with a Promise.
#
# Dependencies:
#
# Configuration:
#   None
#
# Commands:
#   hubot show tasks - Shows all active tasks in robot.brain.tasks
#   hubot clear tasks - Deletes all active tasks
#
# Author:
#   meshachjackson

Tasks = require '../class/tasks'
RSVP = require '../class/promises'
Process = require '../class/process'
Util = require "util"
_ = require 'underscore'

module.exports = (robot) ->

  keygen = (message, topic, skill) ->
    key = topic.replace /\s/, '_'
    skill = skill.replace /\s/, '_'
    return "#{message.user.id}_#{skill}_#{key}"

  findSkill = (robot, skill, topic) ->
    if robot.skills[skill] && robot.brain.get(skill)
      return robot.brain.get(skill)[topic]
    else
      return false

  robot.Response.prototype.process = (skill, topic) ->
    try
      promise = new RSVP.Promise()

      # setup the robot
      if !known = findSkill robot, skill, topic
        promise.reject "Could not validate skills"
        return

      known.message = @message
      known.skill = skill
      known.topic = topic
        
      # do i know how to store tasks?
      robot.brain.tasks = robot.brain.tasks or new Tasks robot

      # generate a unique id
      key = keygen @message, topic, skill

      # create the task...
      if !task = robot.brain.tasks.get(key)
        task = robot.brain.tasks.add(key, known)

      # if task.step == 'end'

      p = new Process()

      p.init(task, robot, this)

      .done (message) ->
        robot.brain.tasks.remove(key)
        promise.resolve message

      .fail (message) ->
        # to have persistent tasks, failures cannot clear the task. Only completion.
        # robot.brain.tasks.remove(key)
        promise.reject message

      return promise

    catch e
      e.locale = __dirname
      @chatty "Trying to process #{skill} #{topic}"
      throw e

# Task Utils...
  robot.respond /show my tasks$/i, (msg) ->
    try
      if robot.brain.tasks
        mytasks = robot.brain.tasks.listByUserId msg.message.user.id, "topic", "skill"
        count = mytasks.length
        if count > 0
          topics = _.pluck mytasks, 'topic'
          skills = _.pluck mytasks, 'skills'
          msg.chatty Util.inspect(mytasks, false, 4)
          msg.chatty "#{skills.length} skills, and #{topics.length} topics.", "Found #{count} of them!"
      else
        msg.chatty "...you like jokes?", "None found."
        if robot.chatty.isChatty
          msg.emote ":-P"
    catch e
      e.locale = __dirname
      msg.chatty robot.chatty.oops "Error trying to show your tasks."
      throw e
    

  robot.respond /show tasks$/i, (msg) ->
    try
      if !robot.brain.tasks
        msg.send "I would love to, but there are none."
      else
        output = Util.inspect(robot.brain.tasks.list(), false, 4)
        msg.send output
        msg.send "Here you go."
    catch e
      e.locale = __dirname
      msg.chatty "Error trying to run #{msg.message.text}"
      throw e

  robot.respond /clear tasks$/i, (msg) ->
    try
      if !robot.brain.tasks
        msg.send "Actually, there are no tasks."
      else
        msg.send "Are you sure?"
        msg.expect(/y/i)
        .done (message) ->
          robot.brain.tasks.clear().list()
        .then (list) ->
          msg.send "Here is the new task list."
        .fail (message) ->
    catch e
      e.locale = __dirname
      msg.chatty "Error trying to run #{msg.message.text}"
      throw e

  robot.respond /test process$/i, (msg) ->
    msg.send "I don't know how to do that yet. Care to teach me? (#{__dirname})"