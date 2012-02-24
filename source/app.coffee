#
# @require:
#   types:      fest/types
#   context:    fest/context
#   string:     fierry/util/string
#   storage:    fierry/util/storage
#

#
# Initiation module for the Fest Framework. Exports global run method
# for running selected tests. Uses 'provider-consumer' pattern to
# track the selected tests & running indicator between the page
# reloads. Provides a RunnerManager singleton that enables client to
# iteratively run previously selected tests.
#



# Storage key for selected tests.
SELECTED_TESTS_KEY = '?!fest.manager.tests'

# Storage key for running indicator. If true indicates that fest
# controller should run the persisted selected tests.
ACTIVE_TESTS_KEY = '?!fest.manager.active'



#
# Global run method. Enables client to run manually selected tests or
# these from the named, saved context. Reloads the page before running
# the tests in order to work on the most recent code.
#
# @param name  {String}  name of the saved tests context, optional.
#
RUN_METHOD = (name) ->
  
  # Get selected tests from the context. 
  tests = context().get(name)

  # Save selected tests into session storage
  storage().set(SELECTED_TESTS_KEY, tests, true) if tests.length

  # Set the running indicator to true in order to trigger controller
  # to run selected tests after the page reloads.
  storage().set(ACTIVE_TESTS_KEY, true, true)

  # Reload the page.
  window.location.reload()


# Export the run method into the global namespace.
F.set_global('run', RUN_METHOD)



#
# Singleton responsible for running the previously selected tests
# belonging to different test types and therefore having different
# runners. 
#
class RunnerManager

  #
  # @param _tests  {Array.<String>}  selected tests, optional.
  #
  constructor: (@_tests = []) ->


  #
  # Runs all continous tests found in the @_selected collection that
  # belongs to the same test type and therefore have the same runner.
  # This method is expected to be invoked after any test runner is
  # done with the given tests.
  #
  run_next: ->
    
    # Return if no tests are found.
    return if @_tests.length is 0

    # Get type instance using type name from the first qualifier.    
    tname = string().substridx(@_tests[0], '.', 1)
    type  = types().get(tname)

    # Collection for retrieved tests instances.
    tests = []

    # Get tests instances whose qualifiers matches the type.
    while @_tests[0]?.indexOf(tname) is 0

      # Get full node name without the type prefix.
      name = @_tests.shift().substr(tname.length + 1)

      # Concat already retrieved tests with these from the node.
      tests = tests.concat(type.get(name).get_tests())

    # Run the retrieved test instances by the proper runner.
    type.runner.run(tests)



# Create a RunnerManager singleton, passing a collection of selected
# tests retrieved from the session storage.
SINGLETON = new RunnerManager(storage().get(SELECTED_TESTS_KEY, true))

# Check if Fest Framework is set to run the tests.
if storage().get(ACTIVE_TESTS_KEY, true)

  # Set the running indicator to false for future reloads.
  storage().set(ACTIVE_TESTS_KEY, false, true)

  # Run all continuous tests that belong to the same test type. 
  SINGLETON.run_next()

# Return RunnerManager singleton as module API.
return SINGLETON
