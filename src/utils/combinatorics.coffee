###
Combinatorics module
### 
module.exports =
  combinations: (list, n) ->
    combs = this._combinations list.length, n
    for indices in combs
      for i in indices
        list[i]

  repcombinations: (arr, k) ->
    return [ [] ] if k == 0
    return [] if arr.length == 0
    chead = ([arr[0]].concat combo for combo in this.repcombinations arr, k-1)
    combos_sans_head = this.repcombinations arr[1...], k
    chead.concat combos_sans_head

  permutation: (input) ->
    set = []
    permute = (arr, data) -> 
      memo = data || []

      for i in [0...arr.length]
        cur = arr.splice(i, 1)[0];
        if arr.length == 0 
          set.push(memo.concat([cur]))
        permute(arr.slice(), memo.concat([cur]))
        arr.splice(i, 0, cur)
      set
    permute(input)

  _clone: (arr) -> (n for n in arr)

  _combinations: (n, p) ->
    return [ [] ] if p == 0
    i = 0
    combos = []
    combo = []
    while combo.length < p
      if i < n
        combo.push i
        i += 1
      else
        break if combo.length == 0
        i = combo.pop() + 1
      if combo.length == p
        combos.push this._clone combo
        i = combo.pop() + 1
    combos