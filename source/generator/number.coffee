#
# @require:
#   array: fierry/util/array.
#


#
# Generator for creating array of unique numbers. Internally
# caches the generated arrays to boost the performance.
#
# @singleton
#
class NumberGenerator

  constructor: ->
    @cache_ = F.get_global_cache('fest/generator/number')


  #
  # Generates array of unique numbers. If step is equal 0, 
  # the result array will contain floats instead of ints.
  #
  # @param length  {Number}   array's length
  # @param step    {Number}   max incrementation step
  # @param sorted  {Boolean}  if true, sorts result array
  #
  array: (count, step = 2, sorted = false) ->
    key = "#{count}_#{step}_#{sorted}"

    return @cache_[key] ?= do =>
      i   = 0
      arr = for j in [1..count]
        i += if step then F.random(step - 1) + 1 else F.random()
      
      array.shuffle(arr) if not sorted
      return arr



return new NumberGenerator()

