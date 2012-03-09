#
# @require:
#   TestCase: fest/lightspeed/test_case
#



return class PerformanceTestCase extends TestCase

  constructor: ->

    # Gathering before_each & after_each arrays of functions.
    @_after_each  = @_grather_after_each()
    @_before_each = @_grather_before_each()

    # Calling the super class constructor.
    super


  _grather_before_each: ->
    array = []

    while node ?= @test
      array.push(node.before_each) if node.before_each
      node = node.parent

    return array.reverse()


  _grather_after_each: ->
    array = []

    while node ?= @test
      array.push(node.after_each) if node.after_each
      node = node.parent

    return array


  _run_test: (args, scope) ->

    # Start date for full test run time.
    start = new Date()

    while args--
      b.call(scope) for b in @_before_each
      @test.run.call(scope)
      a.call(scope) for a in @_after_each

    # Return full test run time
    return new Date() - start


  _run_constants: (args, scope) ->
    
    # Start date for full test run time.
    start = new Date()

    # Full test run loop.
    while args--
      b.call(scope) for b in @_before_each
      a.call(scope) for a in @_after_each

    # Return full test run time
    return new Date() - start


  is_failure: ->
    return @get_ops_per_ms() > 10000


  # TODO moglbym wydzielic informacje dla > 10k, 20k i 30k ops/ms!
  get_failure_text: ->
    return if @is_failure()
    then "Test is too fast for standard performance testing." +
         "The results may be inaccurate. Try rewriting the test" +
         "as a lightspeed test."
    else ""
