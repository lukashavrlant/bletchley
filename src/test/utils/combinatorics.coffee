combinatorics = require '../../utils/combinatorics'

describe 'Combinatorics', () ->
  describe '#combinations()', () ->
    it 'should return a list of all combinations of a given list', () ->
      combinatorics.combinations(['a', 'b', 'c', 'd'], 2).should.eql([['a', 'b'], ['a', 'c'], ['a', 'd'], ['b', 'c'], ['b', 'd'], ['c', 'd']])

      combinatorics.combinations(['a', 'b', 'c', 'd'], 4).should.eql([['a', 'b', 'c', 'd']])

  describe '#repcombinations()', () ->
    it 'should return a list of all combinations with repetition of a given list', () ->
      combinatorics.repcombinations(['a', 'b', 'c', 'd'], 2).should.eql([['a', 'a'], ['a', 'b'], ['a', 'c'], ['a', 'd'], ['b', 'b'], ['b', 'c'], ['b', 'd'], ['c', 'c'], ['c', 'd'], ['d', 'd']])

      combinatorics.repcombinations(['a', 'b', 'c', 'd'], 4).should.eql([["a", "a", "a", "a"],["a", "a", "a", "b"],["a", "a", "a", "c"],["a", "a", "a", "d"],["a", "a", "b", "b"],["a", "a", "b", "c"],["a", "a", "b", "d"],["a", "a", "c", "c"],["a", "a", "c", "d"],["a", "a", "d", "d"],["a", "b", "b", "b"],["a", "b", "b", "c"],["a", "b", "b", "d"],["a", "b", "c", "c"],["a", "b", "c", "d"],["a", "b", "d", "d"],["a", "c", "c", "c"],["a", "c", "c", "d"],["a", "c", "d", "d"],["a", "d", "d", "d"],["b", "b", "b", "b"],["b", "b", "b", "c"],["b", "b", "b", "d"],["b", "b", "c", "c"],["b", "b", "c", "d"],["b", "b", "d", "d"],["b", "c", "c", "c"],["b", "c", "c", "d"],["b", "c", "d", "d"],["b", "d", "d", "d"],["c", "c", "c", "c"],["c", "c", "c", "d"],["c", "c", "d", "d"],["c", "d", "d", "d"],["d", "d", "d", "d"]])

  describe '#permutation()', () ->
    it 'should return list of all permutations of a given list', () ->
      combinatorics.permutation(['a', 'b', 'c']).should.eql([["a", "b", "c"],["a", "c", "b"],["b", "a", "c"],["b", "c", "a"],["c", "a", "b"],["c", "b", "a"]])
