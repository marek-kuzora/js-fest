#
# @require:
#   Group: fest/group
#



return class Type
  
  #
  # @param name    {String}  type name.
  # @param runner  {Object}  type runner.
  #
  constructor: (@name, @runner) ->

    # Root group of the groups hierarchy tree.
    @_root = new Group('', undefined, @name)

    # Last referenced absolute group. Default parent when adding
    # consecutive relative groups.
    @_node_group = @_root

    # Export root selection tree into the global namespace.
    F.set_global(@name, @_root.get_selection_tree())
    

  #
  # Registers a scenario group under the given name.
  #
  # @param name  {String}  group name.
  # @param raw   {Object}  group definition.
  #
  scenario: (name, raw = {}) ->
    raw.scenario = true
    @group(name, raw)


  #
  # Registers a group under the given name.
  #
  # @param name  {String}  group name.
  # @param raw   {Object}  group definition.
  #
  group: (name, raw) ->

    # From the group name: if it's absolute & its full name.
    absolute  = @_is_group_absolute(name)
    full_name = @_resolve_group_name(name, absolute)

    # Retrieve the group parent & create the group inside.
    parent = @get(full_name, true)
    group  = parent.register_group(full_name, raw)
    
    # Set group as the node group if it's absolute.
    @_node_group = group if absolute


  #
  # Returns if the group name is absolute and therefore it is a node
  # group for the groups to come. Otherwise the name is relative and
  # needs to be combined with the current node group in order to
  # retrieve its full name.
  #
  # @param name  {String}   group name.
  # @return      {Boolean}
  #
  _is_group_absolute: (name) ->
    return name[0] is '/'


  #
  # Returns full name from the given group name. If the name is
  # relative, it's concated with the current node group name.
  #
  # @param name      {String}   group name.
  # @param absolute  {Boolean}  is group name absolute.
  # @return          {String}
  #
  _resolve_group_name: (name, absolute) ->

    # Return absolute group name without '/'.
    return name.substr(1) if absolute

    # Return group name as a child of the current node group.
    return @_node_group.get_child_prefix() + name


  #
  # Returns the node corresponding to the given name. Returns parent
  # of that node if parent parameter was set to true.
  #
  # @param full_name  {String}   full node name.
  # @param parent     {Boolean}  looking for node parent.
  # @return           {Node}
  #
  get: (full_name, parent) ->

    # Assign node to root as top node.
    node = @_root

    # Split full name into an array of simple names.
    names = full_name.split('.')

    # Remove last name if looking for node parent.
    names.pop() if parent

    # Traverse through the names.
    for name in names

      # Assert the node is a Group instance.
      if not node instanceof Group
        throw new Error "Node is not a group: #{node.name}"

      # Retrieve child node from the group node.
      node = node.get(name)

    return node
