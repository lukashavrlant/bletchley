trans = require '../../ciphers/trans'

describe 'trans', () ->
  describe '#encrypt()', () ->
    it 'should encrypt opentext', () ->
      trans.encrypt('dobrydencelyden', 'tomas').should.equal('rcebndoeyyenddl')

    it 'should add "x"-es to ciphertext if needed', () ->
      trans.encrypt('dobreranoslovenskodobrounocrobertefico', 'slovensko').should.equal('eeorxnkofxolooornutxbobbxoocixdsdrcasnexrvrex')

    it 'should encrypt empty string without error', () ->
      trans.encrypt('', 'z').should.equal ''

  describe '#decrypt()', () ->
    it 'should decrypt ciphertext', () -> 
      trans.decrypt('rcebndoeyyenddl', 'tomas').should.equal('dobrydencelyden')

    it 'should decrypt ciphertext and keep "x"-es', () ->
      trans.decrypt('rcxbexdyeovr', 'klic').should.equal('dobryvecerxx')

    it 'should decrypt empty string without error', () ->
      trans.decrypt('', 'w').should.equal('')
