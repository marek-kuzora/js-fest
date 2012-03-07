


# Minimum number of runs for a single test case: 1 time.
MIN_RUN_TIMES = 1

# Maximum number of runs for a single test case: 10 000 000 times.
MAX_RUN_TIMES = 10000000



return class LightSpeedTestCase


  constructor: (@test) ->

    # Number of times to run the test case in a loop.
    @_times = @_get_times()

    # Miliseconds to wait before running next test case.
    @timeout = @_get_time_limit(@_times)


  _get_times: ->

    # Starting at 1 test invocation & none time.
    arg  = MIN_RUN_TIMES
    time = 0

    # Run test for the first time to load its environments.
    @run(MIN_RUN_TIMES)

    # Iterate fast over number of invocations when the time is none.
    while time is 0 and arg < MAX_RUN_TIMES
      arg *= 10
      time = @run(arg)

    # Increase number of invocations until the run time is big enough.
    while time < @_get_time_limit(arg) and arg < MAX_RUN_TIMES
      arg *= 2
      time = @run(arg)

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


  run: (times = @_times, measure = false) ->

    # Push new test hierarchy scope.
    F.push_scope()

    # Preload environments.
    F.run(env) for env in @_get_environments()

    # Create test scope.
    scope = {}

    # Run before method.
    @_run_before(scope)

    # Retrieve running times to compare.
    ttime = @_run_test(times, scope)
    trest = if measure then @_run_constant(times, scope) else 0

    # Run after method.
    @_run_after(scope)

    # Cache names of the modules loaded after the first run.
    @_envs ?= F.get_loaded_modules()

    # Remove the test hierarchy scope.
    F.pop_scope()

    # Return final run time or 0 if its negative.
    return if ttime > trest then ttime - trest else 0


  _run_test: (times, scope) ->
    start = new Date()
    @test.run.call(scope, times)
    return new Date() - start


  _run_internal_wrappers: (times, scope) ->
    start = new Date()
    @test.constant.call(scope, times) if @test.constant
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
