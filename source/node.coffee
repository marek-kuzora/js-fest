#
# @require:
#   string: fierry/util/string
#   regexp: fierry/util/regexp
#



return class Node

  #
  # @param name    {String}  node full name.
  # @param parent  {Node}    node parent.
  # @param raw     {Object}  node definition.
  #
  constructor: (@name, @parent, @_type, raw) ->

    # Node simple name.
    @_simple = @name.substr(@parent.get_child_prefix().length)

    # Assert the simple name is selectable.
    if not @_is_selectable(@_simple)
      throw new Error "Simple name '#{@_simple}' is not selectable"

    # Node display name.
    @_display = raw.display || @name

    # Collection of preloaded modules.
    @_envs = raw.envs || []

    # Collection of node dependences (in qa).
    @_dpds = raw.dependences || []

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


  #
  # Returns true if the given name matches variable regexp 
  # and therefore is selectable.
  #
  # @param name  {String}
  # @return      {Boolean}
  #
  _is_selectable: (name) ->
    return regexp().VARIABLE.test(name)


  #
  # Returns the node simple name. Simple name is assured to be
  # selectable, that means the client will be able to treat it as 
  # a normal property when selecting the tests via selection tree.
  #
  # @return  {String}
  #
  get_simple_name: ->
    return @_simple


  #
  # Returns root of the node selection tree. If the node is a group,
  # it will use its root to attach child nodes selection trees by
  # their simple names.
  #
  # @return  {->}  node selection tree root.
  #
  get_selection_tree: ->

    # Assign fully qualified node name.    
    name = if @name then @_type + '.' + @name else @_type

    # Assign the selection function.
    return @_selection ?= ->
      context().select(name)



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
