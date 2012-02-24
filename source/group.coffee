#
# @require:
#   context: fest/context
#   regexp:  fierry/util/regexp
#
#   Node: fest/node
#   Test: fest/test
#



# Reserved group properties. Properties defined below will be used to
# define group parameters, whereas all other group properties will be
# used to create tests.
RESERVED = [
  'after', 'after_each' , 'before', 'before_each' ,
  'envs', 'generators', 'min_arg', 'run', 'scenario'
]


return class Group extends Node

  constructor: (name, parent, type, raw = {}) ->
    super

    # Indicates a scenario group.
    @scenario = raw.scenario || false

    # Collection of group nodes.
    @nodes = []

    # Assert the simple name is selectable.
    if @parent and not @_is_selectable(@simple)
      throw new Error "Simple name '#{@simple}' is not selectable."

    # Update the selection tree.
    parent.get_selection_tree()[@simple] = @get_selection_tree() if parent

    # Create tests from all other not RESERVED properties.
    @_create_tests(raw)


  #
  # Returns true if the given name matches variable regexp and 
  # therefore is selectable.
  #
  # @param name  {String}
  # @return      {Boolean}
  #
  _is_selectable: (name) ->
    return regexp().VARIABLE.test(name)


  #
  # Creates group tests from all not RESERVED properties.
  # If raw.generators is defined, generates additional tests using
  # factories for each provided argument.
  #
  # @param raw  {Object}
  #
  _create_tests: (raw) ->

    # Register inline tests provided in raw hash.
    for name, test of raw when RESERVED.indexOf(name) is -1
      @register_test(name, test)

    # Register tests from factories generated using provided arguments.
    for generator in raw.generators || []
      for argument in generator.args

        # Factory must always return a hash of tests.
        for name, test of generator.factory(argument)
          @register_test(name, test)


  #
  # Creates and adds a new group child node. Attaches child node
  # selection tree into the group selection tree. Throws an error 
  # if the name is duplicated with any of the existing group nodes.
  #
  # @param name   {String}  group name.
  # @param raw    {Object}  group definition.
  #
  # @return       {Group}
  #
  register_group: (name, raw = {}) ->
    
    # Validates group raw hash.
    @_type.group_validator(name, raw)

    # Assert the name is unique.
    for n in @nodes when n.name is name
      throw new Error "Node #{name} already exists"
    
    # Create new node and push it as a group child.
    @nodes.push(group = new Group(name, @, @_type, raw))
    return group


  #
  # Creates and adds a new test child node. Accepts raw as function as
  # a shortcut definition. Throws an error if the name is duplicated
  # with any of the existing group nodes.
  #
  # @param name   {String}  test name.
  # @param raw    {Object}  test definition.
  #
  # @return       {Test}
  #
  register_test: (name, raw = {}) ->

    # Expands the test name.
    name = @get_child_prefix() + name

    # Expands the shortcut test definition.
    if typeof raw is 'function'
      raw = run: raw

    # Validates test raw hash.
    @_type.test_validator(name, raw)

    # Assert the name is unique.
    for n in @nodes when n.name is name
      throw new Error "Node #{name} already exists"

    # Create new node and push it as a group child.
    @nodes.push(test = new Test(name, @, @_type, raw))
    return test


  #
  # Returns node with specified name. Throws an error if no node 
  # is found.
  #
  # @param name  {String}  simple node name.
  # @return      {Node}
  #
  get: (name) ->

    # Prepend group name if the group isn't root.
    name = @get_child_prefix() + name
    
    # Return the node that's name matches.
    return n for n in @nodes when n.name is name

    # Throw an error if no node was found.
    throw new Error "Node not found #{@name}.#{name}"


  #
  # Returns all tests the group and its group nodes contain.
  #
  # @return  {Array.<Test>}
  #
  get_tests: ->
    arr = []
    for n in @nodes
      if n instanceof Test  then arr.push(n)
      if n instanceof Group then arr = arr.concat(n.get_tests())
    return arr


  #
  # Returns name prefix for the child nodes. If the group is a root 
  # it does not have any name - it returns just an empty string.
  # Otherwise returns the group's name concated with a dot.
  #
  # @return  {String}
  #
  get_child_prefix: ->
    return if @name is '' then @name else @name + '.'


  #
  # Returns root of the node selection tree. If the node is a group,
  # it will use its root to attach child nodes selection trees by
  # their simple names.
  #
  # @return  {->}  node selection tree root.
  #
  get_selection_tree: ->

    # Assign fully qualified node name.    
    name = if @name then @_type.name + '.' + @name else @_type.name

    # Assign the selection function.
    return @_selection ?= -> context().select(name)
