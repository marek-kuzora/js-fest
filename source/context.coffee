#
# @require:
#   array:   fierry/util/array
#   storage: fierry/util/storage
#



#
# Returns true if testB is subset of the testA, false otherwise.
#
# @param testA  {String}
# @param testB  {String}
# @return       {Boolean}
#
DUPLICATED_TEST = (testA, testB) ->
    return testA.indexOf(testB + '.') is 0


# Storage key prefix for named tests contexts.
STORAGE_KEY = '?!fest.context.'



#
# Singleton responsible for managing currently selected tests,
# enabling client to persist selected tests as a named context that
# can be later retrieved and exists between page & browser reloads.
#
class Context

  constructor: ->

    # Collection of currently selected nodes.
    @_selected = []


  #
  # Marks the given test qualifier as selected. Selected test
  # qualifiers can later be run by the controller or persisted as a
  # named context. 
  #
  # This method assures that there are no duplicated qualifiers that
  # overlap - for qualifiers: 'pfc.array' and 'pfc.array.erase' the
  # second qualifier is a subset of the first and therefore should be
  # removed.
  #
  # @param qualifier  {String}
  #
  select: (qualifier) ->

    # Return if qualifier is duplicated by already selected nodes.
    for i in @_selected
      return if DUPLICATED_TEST(i, qualifier)

    # Save qualifier as selected.
    @_selected.push(qualifier)

    # Customize DUPLICATED_TEST selector.
    fn = (i) -> return DUPLICATED_TEST(qualifier, i)

    # Erase all nodes that are duplicated by qualifier.
    array().erase_all_cst(@_selected, fn)

  
  #
  # Saves currently selected test qualifiers as named context with the
  # given name. Clears currently selected test qualifiers for a fresh
  # start.
  #
  # @param name  {String}
  #
  save: (name) ->
    storage().set(STORAGE_KEY + name, @_selected)
    @_selected = []


  #
  # Removes named context identified by the given name.
  #
  # @param name  {String}
  #
  remove: (name) ->
    storage().remove(STORAGE_KEY + name)


  #
  # Returns selected test qualifiers. If a name argument is given,
  # returns named context identified by that name or throws an error
  # if such context does not exist. Otherwise returns currently
  # selected test qualifiers.
  #
  # @param name  {String}
  # @return      {Array.<String>}
  #
  get: (name) ->
    
    # Return currently selected tests if no name was given.
    return @_selected if not name

    # Retrieve saved tests context.
    selected = storage().get(STORAGE_KEY + name)

    # Assert the named test context was found.
    if selected is null
      throw new Error "Tests context '#{name}' not found."

    return selected



# Return Context singleton as module API.
return new Context()
