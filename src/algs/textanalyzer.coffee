###
Text analyzer module
###
module.exports =
  occurences: (text) ->
    counter = @counter text
    occ = {}
    occ[k] = (v / text.length) * 100 for k, v of counter
    occ

  similarity: (text, langstats) ->
    freq = @occurences text
    score = 0
    for k, v of freq
      score += Math.pow(v - (langstats.frequency[k] or 0), 2)
    score

  mostMeaningful: (texts, langstats) ->
    meta = []
    [score, index] = [10000, 0]
    for text, i in texts
      tempsim = @similarity text, langstats
      meta.push [text.slice(0,42), tempsim]
      if tempsim < score
        score = tempsim
        index = i
    {'index': index, 'meta': meta}

  counter: (list) ->
    counter = {}
    counter[item] = (if counter[item] then counter[item] + 1 else 1) for item in list
    counter