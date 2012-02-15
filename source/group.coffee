#
# @require:
#   Node: fest/node
#   Test: fest/test
#



return class Group extends Node

  constructor: (name, parent, type, raw = {}) ->
    super

    # Collection of group nodes.
    @nodes = []


  #
  # Creates and adds a new group child node. Attaches child node
  # selection tree into the group selection tree. Throws an error 
  # if the name is duplicated with any of the existing group nodes.
  #
  # @param type   {Class}   node class type.
  # @param name   {String}  node name.
  # @param ttype  {String}  tests type name.
  # @param raw    {Object}  node definition.
  #
  # @return       {Node}
  #
  add: (type, name, ttype, raw) ->

    # Assert the name is unique.
    for n in @nodes when n.name is name
      throw new Error "Node #{name} already exists"
    
    # Create new node and push it as a group child.
    @nodes.push(n = new type(name, @, ttype, raw))

    # Update the selection tree.
    @get_selection_tree()[n.get_simple_name()] = n.get_selection_tree()

    return n


  #
  # Returns node with specified name. Throws an error if no node 
  # is found.
  #
  # @param name  {String}  simple node name.
  #
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
