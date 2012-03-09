#
# @require:
#   manager:  fest/app
#   reporter: fest/lightspeed/reporter
#



return class LightSpeedRunner

  constructor: (@_test_case)->

  run: (@_tests) ->

    # Report found tests.
    reporter().tests_found(@_tests)

    # Process first test from the queue.
    @run_next_test()


  run_next_test: =>

    # If there are no tests to process.
    if not @_tests.length

      # Report finished tests.
      reporter().tests_finished()

      # Return handling to the RunnerManager.
      return manager().run_next()

    else

      # Create test case wrapping actual test. This will perform some
      # time consuming operations. Therefore running the test case
      # should be scheduled as asynchronous invocation to keep the
      # application responsive.
      test = new @_test_case(@, @_tests.shift())

      # Schedule asynchronous execution of the test case.
      setTimeout(test.execute, test.timeout)
