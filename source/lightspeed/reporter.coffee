#
# @require:
#   string: fierry/util/string
#

class LightSpeedReporter

  constructor: ->
    @_group = ''


  tests_found: (tests) ->
    console.log "Found", tests.length, "tests."


  test_finished: (test) ->

    # Switch a group in the console if a new one differs.
    @_switch_groups(test.test.parent.name)

    # Get the proper console log function.
    log = if test.is_failure() then console.warn else console.log

    # Print the test result into the console.
    log.call console,
      @_get_name(test),
      @_get_ops(test), "  ops/ms  ",
      @_get_hash(test)


  tests_finished: ->

    # Close all still open console groups.
    console.groupEnd() for i in [0..@_get_group_length()]

    # Reset all reporter variables.
    @_group= ''
   

  #
  # Changes a console's group heading. When switching preserves
  # the visual structure of the group tree.
  #
  # @param group  {String}
  #
  _switch_groups: (group) ->
    return if @_group is group

    # Split groups into an array of segment names.
    curr = group.split('.')
    prev = @_group.split('.')

    # Skip the same segment names.
    i = 0
    i++ while curr[i] == prev[i]

    # Close group for all unexisting segment names.
    console.groupEnd() for j in [i..prev.length - 1]

    # Open group for all unmatched segment names.
    console.group(curr[j]) for j in [i..curr.length - 1]

    # Set the new group as the current group.
    @_group = group


  #
  # Returns properly formated (with rpad) test name for the output.
  #
  # @param test  {TestCase}
  # @return      {String}
  #
  _get_name: (test) ->
    name = test.test.name.substr(@_group.length + 1)
    return string().rpad(name, @_get_padding())


  #
  # Returns properly formated (with lpad) test ops/ms.
  #
  # @param test  {TestCase}
  # @return      {String}
  #
  _get_ops: (test) ->
    rgx = /(\d+)(\d{3})(\.\d{2})/
    ops = test.get_ops_per_ms().toFixed(2)
    ops = ops.replace(rgx, '$1' + ' ' + '$2$3')

    return string().lpad(ops, 10)

  
  #
  # Returns hash object with additional information about the test.
  #
  # @param test  {TestCase}
  # @return      {Object}
  #
  _get_hash: (test) ->
    hash =
      ' args': test.args + ' times'
      ' runs': test.get_average_run_time().toFixed(2) + " ms"
      
      case: test
      test: test.test

      data:
        runs: test.times
        ops:  test.get_ops_per_ms_all()

    hash.failure = test.get_failure_text() if test.is_failure()
    return hash


  #
  # Returns proper padding for outputting test name. Includes 
  # the group indentation while computing the result.
  #
  # @return  {Number}
  #
  _get_padding: ->
    return 50 - @_get_group_length() * 2


  #
  # Returns number of segment names of the current group name.
  #
  # @return  {Number}
  #
  _get_group_length: ->
    return @_group.split('.').length - 1



return new LightSpeedReporter()
