

return class Node

  #
  # @param name    {String}  node full name.
  # @param parent  {Node}    node parent.
  # @param type    {String}  node type name.
  # @param raw     {Object}  node definition.
  #
  constructor: (@name, @parent, @_type, raw) ->

    # Node simple name.
    # TODO handle no parent!
    @simple = @name.substr(@parent?.get_child_prefix().length || 0)

    # Minimal number of times to run (in pfc).
    @min_arg = raw.min_arg || 0

    # Collection of preloaded modules.
    @_envs = raw.envs || []

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
  run_before: (scope, deep) ->
    @parent.run_before(scope, true) if @parent and deep
    @_before.call(scope)


  run_before_each: (scope, deep) ->
    @parent.run_before_each(scope, true) if @parent and deep
    @_before_each.call(scope)


  run_after: (scope, deep) ->
    @_after.call(scope)
    @parent.run_after(scope) if @parent and deep


  run_after_each: (scope, deep) ->
    @_after_each.call(scope)
    @parent.run_after_each(scope) if @parent and deep
