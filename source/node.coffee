#
# @require:
#   string: fierry/util/string
#   regexp: fierry/util/regexp
#



return class Node

  #
  # @param name    {String}  node full name.
  # @param parent  {Node}    node parent.
  # @param type    {String}  node type name.
  # @param raw     {Object}  node definition.
  #
  constructor: (@name, @parent, @_type, raw) ->

    # Node simple name. 
    @_simple = @name.substr(@parent.get_child_prefix().length)

    # Collection of preloaded modules.
    @_envs = raw.envs || []

    # Minimal number of times to run (in pfc).
    @_min_arg = raw.min_arg || 0

    # Before method for the test.
    @_before = raw.before || (->)

    # Before method for each invocation of the same test (in pfc).
    @_before_each = raw.before_each || (->)

    # After method for the test.
    @_after = raw.after || (->)

    # After method for each invocation of the same test (in pfc).
    @_after_each = raw.after_each || (->)


  # draft
  preload_envs: ->
    F.run(env) for env in @_envs
    return

  
  #
  # Runs before method starting with the top parent group and going down.
  # @param ctx - execution context.
  #

  #
  # Invokes before test setup. Starts with XXX
  #
  run_before: (scope) ->
    @parent.run_before(scope) if @parent
    @_before.call(scope)


  run_before_each: (scope) ->
    @parent.run_before_each(scope) if @parent
    @_before_each.call(scope)


  run_after: (scope) ->
    @_after.call(scope)
    @parent.run_after(scope) if @parent


  run_after_each: (scope) ->
    @_after_each.call(scope)
    @parent.run_after_each(scope) if @parent
