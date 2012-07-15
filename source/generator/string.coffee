#
# Generator for creating array of (mostly) unique strings and
# big random strings. Internally caches the generated arrays to
# boost the performance.
#
# @singleton
#
class StringGenerator

  constructor: ->
    @cache_ = F.get_global_cache('fest/generator/string')
    @min_char_ = 32
    @max_length_ = 20

  #
  # Generates array of unique (mostly) strings.
  #
  # @param count   {Number}
  # @param length  {Number}
  # @param sorted  {Boolean}  if true, retuns sorted array
  # @param range   {Number}   different values of single character
  #
  array: (count, length = 10, sorted = false, range = 95) ->
    key = "array_#{count}_#{length}_#{range}_#{sorted}"

    return @cache_[key] ?= do =>
      arr = @get_string_array_(count, range)
      arr = (str.substr(0, length) for str in arr)

      if sorted then arr.sort()
      return arr


  #
  # Generates hash with unique string properties. Its properties are 
  # generated from StringGenerator.array() method where precentage
  # (defined by ratio) of the array's items will be used as object
  # properties.
  #
  # @param count   {Number}
  # @param length  {Number}
  # @param ratio   {Number}
  # @param range   {Number}
  #
  hash: (count, length = 10, ratio = 100, range = 95) ->
    key = "hash_#{count}_#{length}_#{ratio}_#{range}"

    return @cache_[key] ?= do =>
      keys = @array(count, length, false, range)
      h = {}

      for k, i in keys
        h[k] = i if i % 100 < (ratio)
      return h


  #
  # Generates string of the specified length.
  #
  # @param length  {Number}
  # @param range   {Number}   different values of single character
  #
  big: (length, range = 95) ->
    key = "big_#{length}_#{range}"

    return @cache_[key] ?= do =>
      count = Math.ceil(length / @max_length_)
      arr = @get_string_array_(count, range)
      return arr.join('')


  #
  # Returns array of strings  with the given count & range.
  #
  # @param count  {Number}
  # @param range  {Number}   different values of single character
  #
  get_string_array_: (count, range) ->
    k = "#{count}_#{@max_length_}_#{range}_false"
    return @cache_[k] ?= @gen_string_array_(count, range)

  #
  # Generates array of unique strings with the given count 
  # & range. Each string's lengths is equal to @max_length_.
  #
  # @param count  {Number}
  # @param range  {Number}   different values of single character
  #
  gen_string_array_: (count, range, min_char = @min_char_) ->
    for _ in [1..count]
      arr = for j in [1..@max_length_]
        i = F.random(range) + min_char
        char = String.fromCharCode(i)
      str = arr.join('')


return new StringGenerator()
