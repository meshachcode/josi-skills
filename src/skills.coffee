# Description:
#   Extends brain adding skillz...
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot skill <skill> (of|on|about|in|for|with) <topic> - "skill jokes on lettuce"
#   hubot know any (good )? <skill> - If hubot knows any of these memories, *and* has the 'skill' to run that process, hubot will start that 'skill' with a random selection of the 'topic'
#
# Author:
#   meshachjackson

_ = require 'underscore'

module.exports = (robot) ->
  # skills = potential processes (js objects)
  robot.skills = robot.skills or {}

  robot.brain.on "memories-loaded", (data) =>
    robot.logger.info "Skills Ready to Load!"

  # see all skills
  robot.respond /(show skills|what can you do)/i, (msg) ->
    try
      if robot.skills
        skills = robot.skills
        msg.send "Well, I know..."
        skillList = []
        for k, v of skills
          skillList.push k
        msg.send skillList.join(', ')
      else
        msg.send "robot.skills not loaded."
    catch e
      e.locale = __dirname
      msg.chatty robot.chatty.oops msg.message.text
      throw e

  robot.respond /skill (.+) (of|on|about|in|for|with) (.+)$/i, (msg) ->
    try
      skill = msg.match[1]
      topic = msg.match[3]
      msg.chatty "Okay. I'll try to find the skills to do #{skill} #{msg.match[2]} #{topic}..."
      if robot.brain.get(skill) && robot.skills[skill]
        msg.process(skill, topic)
          .done (result) ->
            msg.emote ":)"
          .fail (message) ->
            msg.send message.why or "\"#{message.text}\", really?"
      else
        msg.chatty "I would really love to learn to do #{skill} on #{topic}...", "None found."
    catch e
      e.locale = __dirname
      msg.chatty "Trying to run #{msg.message.text}"
      throw e

  robot.respond /(let's go )?again$/i, (msg) ->
    try
      if robot.brain.tasks
        tasks = robot.brain.tasks.list()
        keys = _.keys tasks
        msg.send 
    catch e
      e.locale = __dirname
      msg.chatty robot.chatty.oops msg.message.text
      throw e
    

  robot.respond /know any (good )?(.+)/i, (msg) ->
    skill = msg.match[2].replace '?', ''
    try
      if !robot.brain.get(skill)
        throw "Could not find the skill \"#{skill}\""
      if topics = _.keys robot.brain.get(skill)
        topic = msg.random topics
        msg.process(skill, topic)
        .done (message) ->
          msg.send "That was fun!"
        .fail (message) ->
          msg.send message.why or "\"#{message.text}\", really?"
      else
        msg.send "Well, I know how to do #{skill}, but I don't know anything about #{topic}."
    catch e
      e.locale = __dirname
      msg.chatty robot.chatty.oops msg.message.text
      throw e