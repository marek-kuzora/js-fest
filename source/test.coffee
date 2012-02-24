#
# @require:
#   Node: fest/node
#



return class Test extends Node

  constructor: (name, parent, type, raw = {}) ->
    super

    # Indicates an asynchronous test.
    @async = raw.async || false

    # Run method for the test.
    @run = raw.run

    # Assert the run method is defined.
    if not F.is_function(@run)
      throw new Error "Run method not found: #{@name}"

    # Assert the simple name does not contain dot character.
    if @simple.indexOf('.') isnt -1
      throw new Error "Simple name '#{@simple}' contains dot character."


  #
  # Stub method that returns the node as its tests. Exists in order to
  # maintain common API for tests retrieval using their full name.
  #
  # @return  {Test}
  #
  get_tests: ->
    return @
