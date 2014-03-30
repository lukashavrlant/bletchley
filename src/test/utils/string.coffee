string = require '../../utils/string'

describe 'Combinatorics', () ->
  describe '#code()', () ->
    it 'should return a position of a letter in the alphabet', () ->
      for c, i in string.alphabet
        string.code(c).should.equal(i)

  describe '#replaceChars()', () ->
    it 'should replace all characters using the transition table and positions of letters in alphabet', () ->
      string.replaceChars('abcdef', string.alphabet).should.equal('abcdef')
      string.replaceChars('abcdef', 'defghijklmnopqrstuvwxyzabc').should.equal('defghi')

  describe '#isLetter()', () ->
    it 'should return true if the character is a a-z letter, false otherwise', () ->
      for c in string.alphabet
        string.isLetter(c).should.be.true
      string.isLetter('1').should.not.be.true
      string.isLetter('!').should.not.be.true

  describe '#normalizeText()', () ->
    it 'should return a new string with ASCII [a-z] letters only', () ->
      string.normalizeText('ASCII forever!!!').should.equal('asciiforever')
      string.normalizeText('„Premiérovi Robertu Ficovi zůstaly jen oči pro pláč. Dobré ráno, Slovensko. Dobrou noc, Roberte Fico.”').should.equal('premierovirobertuficovizustalyjenociproplacdobreranoslovenskodobrounocrobertefico')

    it 'should return a new string with [a-z] letters and single spaces if keepSpaces = true', () ->
      string.normalizeText('ASCII forever!!!', true).should.equal('ascii forever')
      string.normalizeText('„Premiérovi Robertu Ficovi zůstaly jen oči pro pláč. Dobré ráno, Slovensko. Dobrou noc, Roberte Fico.”', true).should.equal("premierovi robertu ficovi zustaly jen oci pro plac dobre rano slovensko dobrou noc roberte fico")

  describe '#shiftchar()', () ->
    it 'should shift a character to k-next one using alphabet order', () -> 
      string.shiftchar('a', 2).should.equal('c')
      string.shiftchar('z', 2).should.equal('b')
      string.shiftchar('w', 15).should.equal('l')

  describe '#shiftcharback()', () ->
    it 'should shift a character to a k-previous one using alphabet order', () ->
      string.shiftcharback('c', 2).should.equal('a')
      string.shiftcharback('b', 2).should.equal('z')
      string.shiftcharback('l', 15).should.equal('w')

  describe '#isWhiteSpace()', () ->
    it 'should return true if the character is a white space, false otherwise', () ->
      string.isWhiteSpace(' ').should.be.true
      string.isWhiteSpace(' ').should.be.true
      string.isWhiteSpace('\n').should.be.true
      string.isWhiteSpace('s').should.not.be.true
      string.isWhiteSpace('!').should.not.be.true

  describe '#repeat()', () ->
    it 'should repeat a given string to make a new one', () ->
      string.repeat('ab', 2).should.equal('abab')
      string.repeat('aa', 3).should.equal('aaaaaa')
      string.repeat('aa', 0).should.equal('')
      string.repeat('', 10).should.equal('')
