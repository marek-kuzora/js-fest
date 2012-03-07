


return class Test

  #
  # @param name    {String}  node full name.
  # @param parent  {Node}    node parent.
  # @param type    {String}  node type.
  # @param raw     {Object}  node definition.
  #
  constructor: (@name, @parent, @type, raw = {}) ->

    # Run method for the test.
    @run = raw.run

    # Assert the run method is defined.
    if not F.is_function(@run)
      throw new Error "Run method not found: #{@name}"

    # Node simple name.
    @simple = @name.substr(@parent.get_child_prefix().length)

    # Assert the simple name does not contain dot character.
    if @simple.indexOf('.') isnt -1
      throw new Error "Simple name '#{@simple}' contains dot character."

    # Execute type-specific test initialization.
    @type.setup_test(@name, raw, @)

  #
  # Stub method that returns the node as its tests. Exists in order to
  # maintain common API for tests retrieval using their full name.
  #
  # @return  {Test}
  #
  get_tests: ->
    return @
