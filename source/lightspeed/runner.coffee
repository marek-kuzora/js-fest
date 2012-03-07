#
# @require:
#   manager:  fest/app
#   reporter: fest/lightspeed/reporter
#



# Number of times a single test should be executed to get a stable
# time result.
EXECUTE_RETRY = 5



return class LightSpeedRunner

  constructor: (@_test_case_cls)->

  run: (@_tests) ->

    # Report found tests.
    reporter().tests_found(@_tests)

    # Process first test from the queue.
    @_process_test()


  _process_test: =>

    # If there are no tests to process.
    if not @_tests.length

      # Report finished tests.
      reporter().tests_finished()

      # Return handling to the RunnerManager.
      return manager().run_next()
    
    else

      # Reset the counter to EXECUTE_RETRY times.
      @_counter = EXECUTE_RETRY

      # Create test case wrapping actual test. This will perform some
      # time consuming operations. Therefore running the test case
      # should be scheduled as asynchronous invocation to keep the
      # application responsive.
      @_test_case = new @_test_case_cls(@_tests.shift())

      # Schedule asynchronous processing of the test case.
      setTimeout(@_process_test_case, @_test_case.timeout)


  _process_test_case: =>

    # Run the test case.
    time = @_test_case.run()

    # Report finished test case.
    reporter().test_case_finished(@_test_case, time)

    # Schedule asynchronous processing of the next test or test case.
    # TODO more - about counter!
    return setTimeout(@_process_test, @_test_case.timeout) if --@_counter is 0
    return setTimeout(@_process_test_case, @_test_case.timeout)
