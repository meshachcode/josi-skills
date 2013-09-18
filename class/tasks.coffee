_ = require "underscore"

# hold all on-going tasks in the brain for persistence
class Tasks
  store: {}
  constructor: (robot) ->
    @

  add: (key, d) ->
    try
      @store[key] = d
      @store[key].step = 'start'
      @store[key]
    catch e
      throw new Error "Could not add task.", e

  remove: (key) ->
    delete @store[key]

  get: (key) ->
    @store[key]

  list: () -> @store

  listByUserId: (id) ->
    try
      result = [ ]
      for task of (@store or { })
        if id is @store[task].message.user.id
          result.push @store[task]
      return result
    catch e
      e.locale = __dirname
      msg.chatty "Trying to run #{msg.message.text}"
      throw e

  # a "safe" delete for all private data
  clear: () ->
    @store = {}
    @

  count: () ->
    c = 0
    for k, v of @store
      c += _.keys(v).length
    c

module.exports = Tasks