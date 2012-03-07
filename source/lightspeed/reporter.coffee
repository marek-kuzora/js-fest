class LightSpeedReporter

  constructor: ->
    @_group   = ''
    @_counter = 0


  tests_found: (tests) ->
    console.log "Found", tests.length, "tests."


  test_case_finished: (test_case, time) ->
    console.log "Finished test #{test_case.test.name} with #{test_case._times} times in #{time} ms. It's #{~~(test_case._times/time)} ops/ms."


  tests_finished: ->
    console.log "Fihished all tests"



return new LightSpeedReporter()
