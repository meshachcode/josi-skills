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
#   None
#
# Author:
#   meshachjackson

Skill = require '../class/skill.coffee'

module.exports = (robot) ->
  namespace = "jokes"

  robot.brain.on "memories-loaded", (data) =>
    # make sure there are jokes...
    if data[namespace] && robot.skills
      robot.skills[namespace] = new Skill namespace, robot