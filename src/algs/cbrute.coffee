caesar = require '../ciphers/caesar'
textanalyzer = require './textanalyzer'
string = require '../utils/string'

###
Caesar Brute Force module
###
module.exports =
  crack: (ciphertext, langstats) ->
    texts = (caesar.decrypt ciphertext, key for key in string.alphabet)
    result = textanalyzer.mostMeaningful texts, langstats
    return {'key': string.alphabet[result.index], 'meta': result.meta}