#
# @require:
#   reporter: fest/performance/reporter
# 



# Number of times a single test should be executed to get 
# a stable time result.
EXECUTE_RETRY = 5

# Minimum number of runs for a single test case: 1 time.
MIN_RUN_TIMES = 1

# Maximum number of runs for a single test case: 10 000 000 times.
MAX_RUN_TIMES = 10000000



return class LightSpeedTestCase

  constructor: (@_runner, @test) ->

    # Number of times the test should be run in a loop.
    @args = @_measure_run_args()

    # Collection of the test run times.
    @times = []

    # Miliseconds to wait before running test invocation.
    @timeout = @_get_time_limit(@args)

    # Number of times the test should be executed asynchronously.
    @_counter = EXECUTE_RETRY


  execute: =>

    # Run the test & store it's run time.
    @times.push(@run())

    # If the test was executed EXECUTE_RETRY times.
    if --@_counter is 0

      # Report finished test case.
      reporter().test_finished(@)

      # Schedule asynchronous processing of the next test.
      setTimeout(@_runner.run_next_test, @timeout)

    else

      # Schedule another asynchronous execution.
      setTimeout(@execute, @timeout)


  _measure_run_args: ->

    # Starting at 1 test invocation & none time.
    arg  = MIN_RUN_TIMES
    time = 0

    # Run test for the first time to load its environments.
    @run(MIN_RUN_TIMES)

    # Iterate fast over number of invocations when the time is none.
    while time is 0 and arg < MAX_RUN_TIMES
      arg *= 10
      time = @run(arg, true) # changed recently!

    # Increase number of invocations until the run time is big enough.
    while time < @_get_time_limit(arg) and arg < MAX_RUN_TIMES
      arg *= 2
      time = @run(arg, true) # changed recently!

    # Normalize the number of runs to match the appropriate run time.
    return ~~(10 * arg * @_get_time_limit(arg) / @run(arg))


  #
  # Returns the amount of the time the test should be measured before
  # calculating its final run times. The solid numbers are given in
  # the table below. Limit times for values in between are calculated
  # using lineral interpolation.
  #
  #     1x | 10 ms
  #    25x | 25 ms
  #   250x | 25 ms
  # 1 000x | 10 ms
  # 5 000x |  5 ms
  #
  # @param arg    {Number}
  # @return time  {Number}
  #
  _get_time_limit: (arg) ->

    return 10                             if arg is 1
    return 0.625 * (arg - 1) + 10         if arg < 25
    return 25                             if arg < 250
    return -0.02 * (arg - 250) + 25       if arg < 1000
    return -0.0008 * (arg - 1000) + 10    if arg < 5000
    return 5


  run: (args = @args, measure = false) ->

    # Push new test hierarchy scope.
    F.push_scope()

    # Preload environments.
    F.run(env) for env in @_get_environments()

    # Create test scope.
    scope = {}

    # Run before method.
    @_run_before(scope)

    # Retrieve running args to compare.
    ttime = @_run_test(args, scope)
    trest = if not measure then @_run_constants(args, scope) else 0

    # Run after method.
    @_run_after(scope)

    # Cache names of the modules loaded after the first run.
    @_envs ?= F.get_loaded_modules()

    # Remove the test hierarchy scope.
    F.pop_scope()

    # Return final run time or 0 if its negative.
    return if ttime > trest then ttime - trest else 0


  _run_test: (args, scope) ->
    start = new Date()
    @test.run.call(scope, args)
    return new Date() - start


  _run_constants: (args, scope) ->
    start = new Date()
    @test.constant.call(scope, args) if @test.constant
    return new Date() - start


  _run_before: (scope, node = @test) ->
    @_run_before(scope, node.parent) if node.parent
    node.before.call(scope)
    

  _run_after: (scope) ->
    node = @test

    node.after.call(scope)
    node.after.call(scope) while node = node.parent


  _get_environments: ->
    node = @test

    envs = @test.envs
    envs = envs.concat(node.envs) while node = node.parent
    
    return envs


  get_ops_per_ms_all: ->
    return (@args/time for time in @times)


  get_ops_per_ms: ->
    return @args / @get_average_run_time()


  get_average_run_time: ->
    time  = 0
    time += t for t in @times
    return time / EXECUTE_RETRY


  is_failure: ->
    return false


  get_failure_text: ->
    return null
