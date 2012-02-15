#
# @require:
#   Node: fest/node
#



return class Test extends Node

  constructor: (name, parent, type, raw = {}) ->
    super

    # Run method for the test.
    @_run = raw.run

    # Assert the run method is defined.
    if not F.is_function(@_run)
      throw new Error "Run method not found: #{@name}"


  #
  # Stub method that returns the node as its tests. Exists in order to
  # maintain common API for tests retrieval using their full name.
  #
  # @return  {Test}
  #
  get_tests: ->
    return @
