#
# @require:
#   types:    fest/types
#
#   Runner:   fest/lightspeed/runner
#   TestCase: fest/lightspeed/test_case
#



return types().create 'performance',

  # Runner running the lightspeed tests.   
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

    # After method for the test.
    @after = node.after || (->)

    # Collection of preloaded modules.
    @envs = node.envs || []

    # Constant method for the node. It's purpose is to wrap all 
    # time-consuming run operations that cannot be moved from 
    # the while loop. TestRunner will substract run-time of this
    # method from the main run method run-time.
    @constant = node.constant


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
  # Reserved group properties. Properties defined below will be used to
  # define group parameters, whereas all other group properties will be
  # used to create tests.
  #
  reserved: ['after', 'before', 'constant']
