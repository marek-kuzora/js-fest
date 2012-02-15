#
# @require:
#   Type: fest/type
#


#
# Singleton responsible for storing existing test types. Each test
# type is associated with a name and a runner for executing the
# selected tests. This singleton enables clients to create new test
# types and retrieve them by simple name.
#
class Types

  constructor: ->

    # Associative array storing test types.
    @_types = {}


  #
  # Creates new test type and returns it to the client.
  # Throws an error if a type with the given name already exists.
  #
  # @param name    {String}  test type symbolic name.
  # @param runner  {Object}  runner for running the tests.
  # @return        {Type}
  #
  create: (name, runner) ->
    if @_types[name]
      throw new Error "Type '#{name}' already defined."

    return @_types[name] = new Type(name, runner)


  #
  # Returns the test type with the given name. 
  # Throws an error if no type is found.
  #
  # @param name  {String}  test type symbolic name.
  # @return      {Type}
  #
  get: (name) ->
    if not @_types[name]
      throw new Error "Type '#{name}' not found."

    return @_types[name]
