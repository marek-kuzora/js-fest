#
# @require:
#   types:    fest/types
#
#   Runner:   fest/lightspeed/runner
#   TestCase: fest/performance/test_case
#



return types().create 'performance',

  # Runner running the performance tests. 
  runner: new Runner(TestCase)
  

  #
  # Additional node initialization code.
  #
  # @param name  {String}  node name.
  # @param node  {Object}  node definition.
  #
  node: (name, node) ->

    # Before method for the node.
    @before = node.before || (->)

    # Before method for each invocation of the same node.
    @before_each = node.before_each

    # After method for the test.
    @after = node.after || (->)

    # After method for each invocation of the same node.
    @after_each = node.after_each

    # Collection of preloaded modules.
    @envs = node.envs || []


  #
  # Additional test initialization code. 
  #
  # @param name  {String}  test name.
  # @param test  {Object}  test definition.
  #
  test: (name, test) ->

    # Assert the test isnt asynchronous.
    if test.async
      throw new Error "Performance tests cannot be asynchronous: #{name}"


  #
  # Additional group initialization code.
  #
  # @param name   {String}  group name.
  # @param group  {Object}  group definition.
  #
  group: (name, group) ->

    # Assert the group isnt a scenario.
    if group.scenario
      throw new Error "Performance groups cannot be scenarios: #{name}"


  #
  # Additional reserved group properties.
  #
  reserved: ['after', 'after_each', 'before', 'before_each']
