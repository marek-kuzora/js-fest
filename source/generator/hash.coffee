#
# @require:
#   array: fierry/util/array.
#



class HashGenerator

  constructor: ->
    @cache_ = F.get_global_cache('fest/generator/hash')

  array: (count, sorted = false) ->
    key = "#{count}_#{sorted}"

    return @cache_[key] ?= do =>
      F.uid(h) for h in arr = ({} for i in [1..count])
      array.shuffle(arr) if not sorted
      return arr



return new HashGenerator()
