_ = require '../libs/underscore'
require '../utils/underext'

cbrute = require '../algs/cbrute'
triangle = require '../algs/triangle'
viglength = require '../algs/viglength'
vigcompute = require '../algs/vigcompute'
friedman = require '../algs/friedman'

caesar = require '../ciphers/caesar'
vigenere = require '../ciphers/vigenere'
trans = require '../ciphers/trans'
mono = require '../ciphers/mono'

string = require '../utils/string'
statistics = require '../utils/statistics'
combinatorics = require '../utils/combinatorics'


###
GUI module
###
highlight = (text, word, index, color, padding = 15) ->
  startindex = Math.max index - padding, 0
  "&hellip;" + text.slice(startindex, index) + "<b style='color: #{color}'>" + text.slice(index, index+word.length) + "</b>" + text.slice(index+word.length, index+word.length+padding) + "&hellip;"

initCrackCaesar = () ->
  document.getElementById('brute-caesar-crack').onclick = () ->
    crackKey = document.getElementById('brute-crack-key')
    ciphertext = string.normalizeText document.getElementById('brute-input-text').value
    if ciphertext
      result = cbrute.crack ciphertext, statistics
      key = result['key']
      if key
        opentext = caesar.decrypt ciphertext, key
        crackKey.innerHTML = "<strong>Klíč: #{key}</strong>"
        textel = document.getElementById('brute-crackresult')
        textel.style.display = 'block';
        textel.value = opentext
      else
        crackKey.innerHTML = "<strong>Klíč: ???</strong> Analýza se nezdařila."
      temphtml = "<p>Následující tabulka ukazuje dešifrované texty pro všech 26 klíčů Caesarovy šifry. Na každém řádku je kromě části textu ještě použitý klíč a vypočítaná odchylka. My hledáme nejnižší odchylku, takže řádek s nejnižší odchylkou bude obsahovat i vypočítaný klíč.</p>"
      temphtml += "<div class='clear'></div>"
      temphtml += "<table class='with-border with-margin'><tr><th>Klíč</th><th>Část textu</th><th>Odchylka</th></tr>"
      for i in [0..25]
        style = if string.alphabet[i] == result.key then "color: red; font-weight: bold;" else ""
        temphtml += "<tr style='#{style}'><td>#{string.alphabet[i]}</td><td>#{result.meta[i][0]}...</td><td>#{Math.round(result.meta[i][1])}</td></tr>"
      temphtml += "</table>"
      document.getElementById('brute-crack-meta').innerHTML = temphtml;
    return false

processtext = (fun) -> 
  keepSpaces = document.getElementById('cipher-keep-spaces').checked
  text = string.normalizeText document.getElementById('cipher-input-text').value, keepSpaces
  key = document.getElementById('cipher-key').value.toLowerCase()
  document.getElementById('cipher-output').value = fun text, key
  document.getElementById('cipher-output').style.display = 'block'

encrypttextdriver = (encryptfun, decryptfun) ->
  document.getElementById('cipher-encrypt').onclick = () ->
    processtext encryptfun
    false

  document.getElementById('cipher-decrypt').onclick = () ->
    processtext decryptfun
    false

vigenereSquare = () ->
  temphtml = "<table class='with-border'>"
  for i in [0..26]
    temphtml += "<col>"
  temphtml += "<tr><td></td>"
  for c in string.alphabet
    temphtml += "<td><b>#{c}</b></td>"
  temphtml += "</tr>"
  for c in string.alphabet
    ciphertext = caesar.encrypt(string.alphabet, c)
    temphtml += "<tr><td><b>#{c}</b></td>"
    for d in ciphertext
      temphtml += "<td>#{d}</td>"
    temphtml += "</tr>"
  temphtml += "</table>"
  temphtml


initVigenere = () -> 
  encrypttextdriver vigenere.encrypt, vigenere.decrypt
  document.getElementById('vigeneruv-ctverec-platno').innerHTML = vigenereSquare()
  $('#vigeneruv-ctverec-platno td').hover(() ->
    $(this).parents('table').find('col:eq('+$(this).index()+')').toggleClass('hover'))

initCaesar = () ->
  document.getElementById('caesar-d').innerHTML = caesar.showTable 'd'
  document.getElementById('caesar-custom').innerHTML = caesar.showTable 'd'
  document.getElementById('caesar-custom-submit').onclick = () ->
    key = document.getElementById('caesar-custom-key').value.toLowerCase()
    if /[a-z]/.test(key)
      document.getElementById('caesar-custom').innerHTML = caesar.showTable key
    false
  encrypttextdriver ((a, b) -> caesar.encrypt(a, b)), ((a, b) -> caesar.decrypt(a, b)) 

initVigLength = () ->
  viglengthbutton = document.getElementById('viglength-cipher-crack')
  ajaxloader = document.getElementById('viglength-ajax-loader')
  viglengthbutton.onclick = () ->
    if !window.Worker
      alert 'Váš prohlížeč bohužel není podporovaný, protože neumí WebWorkers :-(. Zkuste použít nějaký normálnější prohlížeč...'
      return false
    crackKey = document.getElementById('viglength-crack-key')
    ciphertext = string.normalizeText document.getElementById('viglength-input-text').value
    keylen = parseInt(document.getElementById('viglength-length').value, 10)
    if ciphertext and keylen
      worker = new Worker('content/javascript/kryptografie/bin/workers.js?' + new Date().getTime())
      viglengthbutton.disabled = true
      ajaxloader.style.display = 'inline'
      worker.postMessage({'keylen': keylen, 'ciphertext': ciphertext, 'statistics': statistics, 'action': 'viglength'})
      worker.onmessage = (event) ->
        viglengthbutton.disabled = false
        ajaxloader.style.display = 'none'
        result = event.data
        key = result.key
        if key
          opentext = vigenere.decrypt ciphertext, key
          crackKey.innerHTML = "<strong>Nalezený klíč: <span class='highlightkey'>#{key}</span></strong><br><strong>Dešifrovaný text:</strong>"
          textel = document.getElementById('viglength-crackresult')
          textel.style.display = 'block';
          textel.value = opentext
        else
          crackKey.innerHTML = "<strong>Klíč: ???</strong> Analýza se nezdařila."

        temphtml = "<p style='margin-top: 15px'>Následující tabulka zobrazuje jak probíhalo prolamování. Šifrový text se nejprve rozdělil do #{keylen} bloků textu a každý blok se zvlášť dešifroval pomocí Caesarovy šifry. V prvním řádku je tak 1., #{1+keylen}., #{1+2*keylen}., &hellip; písmeno otevřeného textu, ve druhém řádku je 2., #{2+keylen}., #{2+2*keylen}., &hellip; písmeno otevřeného textu atp. Ke každému bloku tak přísluší jeden klíč. Jejich spojením vznikne hledaný klíč Vigenèrovy šifry. </p>"
        temphtml += "<table class='with-border with-margin'>"
        temphtml += "<tr><th>Bloky textu</th><th>Klíč</th></tr>"
        for line in result.meta
          temphtml += "<tr><td>#{line[0]}&hellip;</td><td>#{line[1]}</td>"
        temphtml += "</table>"
        document.getElementById('viglength-crack-meta').innerHTML = temphtml;
    false

initVigLengthGuess = () ->
  vigcrackbutton = document.getElementById('cipher-crack')
  ajaxvigloader = document.getElementById('vigcrack-ajax-loader')
  vigcrackbutton.onclick = () ->
    if !window.Worker
      alert 'Váš prohlížeč bohužel není podporovaný, protože neumí WebWorkers :-(. Zkuste použít nějaký normálnější prohlížeč...'
      return false

    maxkeylen = Math.max(2, parseInt(document.getElementById('maxkeylen').value, 10) or 20)
    crackKey = document.getElementById('crack-key')
    ciphertext = string.normalizeText document.getElementById('input-text').value
    if ciphertext
      worker = new Worker('content/javascript/kryptografie/bin/workers.js?' + new Date().getTime())
      vigcrackbutton.disabled = true
      ajaxvigloader.style.display = 'inline'
      worker.postMessage({'action':'vigcrack', 'ciphertext': ciphertext, 'statistics': statistics, 'maxkeylen': maxkeylen})
      worker.onmessage = (event) ->
        vigcrackbutton.disabled = false
        ajaxvigloader.style.display = 'none'
        result = event.data
        key = result.key
        if key
          opentext = vigenere.decrypt ciphertext, key
          crackKey.innerHTML = "<strong>Nalezený klíč: <span class='highlightkey'>#{key}</span></strong><br><strong>Dešifrovaný text:</strong>"
          textel = document.getElementById('crackresult')
          textel.style.display = 'block';
          textel.value = opentext
        else
          crackKey.innerHTML = "<strong>Klíč: ???</strong> Analýza se nezdařila."
        temphtml = "<p style='margin-top: 15px'>Následující tabulka zobrazuje jak probíhalo prolamování. Algoritmus zkusil text prolomit s tím, že postupně zkoušel délku klíče 2, 3, 4, &hellip;, #{maxkeylen}. Pro každou délku zjistil nejlepší možný klíč a nakonec dešifroval širový text s pomocí všech klíčů, spočítal odchylku a vrátil ten klíč, který vykazoval nejnižší odchylku.</p>"
        if maxkeylen >= 18 and key == 'instagram' and result.meta[7][1] == 'digitalnihipsterkdesevzalicimsevyznacujiaj'
          temphtml += "<p>Můžete si všimnout, že výsledným klíčem je <i>instagram</i> s odchylkou 18, přitom na třetím řádku od konce je klíč <i>instagraminstagram</i> &mdash; tedy klíč, který povede ke stejnému otevřenému textu. Přesto má vyšší odchylku, 26. Zobrazená odchylka je totiž navíc vážená délkou klíče &mdash; preferují se kratší klíče.</p>"
        temphtml += "<table class='with-border with-margin'>"
        temphtml += "<tr><th>Klíč</th><th>Dešifrovaný text s daným klíčem</th><th>Odchylka</th></tr>"
        for line in result.meta
          style = if line[0] == key then 'color: red; font-weight:bold;' else ''
          temphtml += "<tr style='#{style}'><td>#{line[0]}</td><td>#{line[1]}&hellip;</td><td>#{line[2]}</td></tr>"
        temphtml += "</table>"
        document.getElementById('crack-meta').innerHTML = temphtml
    false

initCrackCaesarDistance = () ->
  document.getElementById('caesar-crack').onclick = () ->
    crackKey = document.getElementById('crack-key')
    ciphertext = string.normalizeText document.getElementById('input-text').value
    if ciphertext
      result = triangle.crack ciphertext, statistics
      key = result['key']
      if key
        opentext = caesar.decrypt ciphertext, key
        crackKey.innerHTML = "<strong>Klíč: #{key}</strong>"
        textel = document.getElementById('crackresult')
        textel.style.display = 'block';
        textel.value = opentext
      else
        crackKey.innerHTML = "<strong>Klíč: ???</strong> Analýza se nezdařila."
      lLetters = result.meta.toplLetters
      langDist = result.meta.toplangDist
      temphtml = ""
      temphtml += "<p>Nejčastější písmena v českém textu jsou: #{lLetters}. Jejich vzdálenost: #{langDist} ve smyslu |#{lLetters[0]}, #{lLetters[1]}| = #{langDist[0]}, |#{lLetters[0]}, #{lLetters[2]}| = #{langDist[1]}, |#{lLetters[1]}, #{lLetters[2]}| = #{langDist[2]}</p>"
      temphtml += "<p>Nejčastější písmena v šifrovém textu: #{result.meta.topcLetters}. Všechny <a href='./permutace'>permutace</a> trojic písmen plus jejich vzdálenosti jsou zobrazeny v následující tabulce.</p>"
      temphtml += "<p>V tabulce je dále zvýrazněná ta trojice písmen, která nejspíš odpovídá třem nejčastějším písmenům v českém jazyce, tj. písmenům #{lLetters}. Algoritmus ještě provádí tentýž postup s písmeny, které se vyskytují nejméně často (to už zde není zobrazeno) &mdash; proto zde nemusí být zvýrazněná žádná trojice, přesto algoritmus uhádne klíč. Může být naopak zvýrazněno i více klíčů, algoritmus pak vybere ten klíč, jehož odpovídající dešifrovaný text dává větší smysl.</p>"
      temphtml += "<div class='clear'></div>"
      temphtml += "<table class='with-border with-margin with-padding'>"
      columns = 4
      counter = 0
      temp = ""
      for metadist in result.meta.topDistances
        if counter < columns
          style = if counter == (columns - 1) then "" else "border-right: 2px solid black;"
          counter += 1
          emph = if _.isEqual metadist[1], langDist then "color: red; font-weight: bold;" else ""
          temp += "<td style='#{emph}'>#{metadist[0]}</td><td style='#{style} #{emph}'>#{metadist[1]}</td>"
        else 
          counter = 0
          temphtml += "<tr>#{temp}</tr>"
          temp = ""
      temphtml += "</table>"

      document.getElementById('crack-meta').innerHTML = temphtml;
    return false

initVig3 = () ->
  vigcrackbutton = document.getElementById('cipher-crack')
  ajaxvigloader = document.getElementById('vigcrack-ajax-loader')
  vigcrackbutton.onclick = () ->
    if !window.Worker
      alert 'Váš prohlížeč bohužel není podporovaný, protože neumí WebWorkers :-(. Zkuste použít nějaký normálnější prohlížeč...'
      return false

    crackKey = document.getElementById('crack-key')
    ciphertext = string.normalizeText document.getElementById('input-text').value
    if ciphertext
      worker = new Worker('content/javascript/kryptografie/bin/workers.js?' + new Date().getTime())
      vigcrackbutton.disabled = true
      ajaxvigloader.style.display = 'inline'
      minlen = 4
      worker.postMessage({'action':'vigkeylenfind', 'minlen': minlen, 'ciphertext': ciphertext, 'statistics': statistics})
      worker.onmessage = (event) ->
        vigcrackbutton.disabled = false
        ajaxvigloader.style.display = 'none'
        result = event.data
        key = result.key
        textel = document.getElementById('crackresult')
        if key
          opentext = vigenere.decrypt ciphertext, key
          crackKey.innerHTML = "<strong>Nalezený klíč: <span class='highlightkey'>#{key}</span></strong><br><strong>Dešifrovaný text:</strong>"
          
          textel.style.display = 'block';
          textel.value = opentext
        else
          crackKey.innerHTML = "<p><strong>Klíč: ???</strong> Analýza se nezdařila, v textu neexistují žádné shodné bloky textu délky alespoň #{minlen}.</p>"
          document.getElementById('crack-meta').innerHTML = ""
          textel.style.display = 'none'
          return false

        temphtml = ""
        indices = result.words

        if !_.isEmpty indices
          temphtml += "<p class='with-margin'>V následující tabulce jsou vypsány všechny shodné bloky textu, které byly nalezeny. Modře jsou zvýrazněny výskyty stejného textu v šifrovém textu, červeně jsou zvýrazněny odpovídající bloky v otevřeném textu. </p>"
          temphtml += "<table class='with-border with-margin'>"
          if indices.rgjelvy and indices.hujnwec
            temphtml += "<p>Všimněte si, že algoritmus našel celkem dvě slova, která se v šifrovém textu opakují na více místech. Přitom první slovo, &bdquo;rgjelvy&ldquo;, odpovídá textu &bdquo;enskych&ldquo; v otevřeném textu. Ale jeden výskyt je tvořen slovem &bdquo;cistirenskych&ldquo; a druhý výskyt jiným slovem, &bdquo;plzenskych&ldquo;. Druhé slovo, „hujnwec“, se už namapuje na stejné slovo: „odpadni“.</p>"
          alldivisors = []
          for word, ind of indices
            temphtml += "<tr><th style='text-align: center;width:66%'>V šifrovém textu se opakovalo slovo &bdquo;#{word}&ldquo;</th><th>Informace</th></tr>"
            for pair in combinatorics.combinations ind, 2
              distance = Math.abs pair[0] - pair[1]
              divisors = vigcompute.divisors(distance).sort((a, b) -> a - b).join ', '
              alldivisors = alldivisors.concat divisors
              openh = highlight opentext, word, pair[0], 'red'
              ciph = highlight ciphertext, word, pair[0], 'blue'
              temphtml += "<tr><td>#{ciph}</td><td>Vzdálenost: #{distance}</td></tr>"
              temphtml += "<tr><td>#{openh}</td><td rowspan='3'>Dělitelé: #{divisors}</td></tr>"
              openh = highlight opentext, word, pair[1], 'red'
              ciph = highlight ciphertext, word, pair[1], 'blue'
              temphtml += "<tr><td>#{ciph}</td></tr>"
              temphtml += "<tr><td>#{openh}</td></tr>"
          temphtml += "</table>"

        temphtml += "<p class='with-margin'>V další tabulce jsou ukázány všechny klíče, které byly vyzkoušeny.</p>"
        temphtml += "<table class='with-border with-margin'>"
        temphtml += "<tr><th>Délka klíče</th><th>Klíč</th><th>Dešifrovaný text s daným klíčem</th><th>Odchylka</th></tr>"
        for line in result.meta
          style = if line[0] == key then 'color: red; font-weight:bold;' else ''
          if line[0].length > 20
            shortkey = line[0].slice(0, 20) + "..."
          else
            shortkey = line[0]
          temphtml += "<tr style='#{style}'><td>#{line[0].length}</td><td title='#{line[0]}'>#{shortkey}</td><td>#{line[1]}&hellip;</td><td>#{line[2]}</td></tr>"
        temphtml += "</table>"
        document.getElementById('crack-meta').innerHTML = temphtml
        
    false


initFriedman = () ->
  vigcrackbutton = document.getElementById('cipher-crack')
  ajaxvigloader = document.getElementById('ajax-loader')
  vigcrackbutton.onclick = () ->
    if !window.Worker
      alert 'Váš prohlížeč bohužel není podporovaný, protože neumí WebWorkers :-(. Zkuste použít nějaký normálnější prohlížeč...'
      return false

    crackKey = document.getElementById('crack-key')
    ciphertext = string.normalizeText document.getElementById('input-text').value
    if ciphertext
      worker = new Worker('content/javascript/kryptografie/bin/workers.js?' + new Date().getTime())
      vigcrackbutton.disabled = true
      ajaxvigloader.style.display = 'inline'
      worker.postMessage({'action':'friedman', 'ciphertext': ciphertext, 'statistics': statistics})
      worker.onmessage = (event) ->
        vigcrackbutton.disabled = false
        ajaxvigloader.style.display = 'none'
        result = event.data
        key = result.key
        if key
          opentext = vigenere.decrypt ciphertext, key
          crackKey.innerHTML = "<strong>Nalezený klíč: <span class='highlightkey'>#{key}</span></strong><br><strong>Dešifrovaný text:</strong>"
          textel = document.getElementById('crackresult')
          textel.style.display = 'block';
          textel.value = opentext
        else
          crackKey.innerHTML = "<strong>Klíč: ???</strong> Analýza se nezdařila."

        temphtml = ""
        indices = result.words

        if !_.isEmpty indices
          temphtml += "<p class='with-margin'>V následující tabulce jsou vypsány všechny shodné bloky textu, které byly nalezeny (<a href='./kasiskeho-test'>Kasiského test</a>). Modře jsou zvýrazněny výskyty stejného textu v šifrovém textu, červeně jsou zvýrazněny odpovídající bloky v otevřeném textu. </p>"
          temphtml += "<table class='with-border with-margin'>"
          if indices.rgjelvy and indices.hujnwec
            temphtml += "<p>Všimněte si, že algoritmus našel celkem dvě slova, která se v šifrovém textu opakují na více místech. Přitom první slovo, &bdquo;rgjelvy&ldquo;, odpovídá textu &bdquo;enskych&ldquo; v otevřeném textu. Ale jeden výskyt je tvořen slovem &bdquo;cistirenskych&ldquo; a druhý výskyt jiným slovem, &bdquo;plzenskych&ldquo;. Druhé slovo, „hujnwec“, se už namapuje na stejné slovo: „odpadni“.</p>"
          alldivisors = []
          for word, ind of indices
            temphtml += "<tr><th style='text-align: center;width:66%'>V šifrovém textu se opakovalo slovo &bdquo;#{word}&ldquo;</th><th>Informace</th></tr>"
            for pair in combinatorics.combinations ind, 2
              distance = Math.abs pair[0] - pair[1]
              divisors = vigcompute.divisors(distance).sort((a, b) -> a - b).join ', '
              alldivisors = alldivisors.concat divisors
              openh = highlight opentext, word, pair[0], 'red'
              ciph = highlight ciphertext, word, pair[0], 'blue'
              temphtml += "<tr><td>#{ciph}</td><td>Vzdálenost: #{distance}</td></tr>"
              temphtml += "<tr><td>#{openh}</td><td rowspan='3'>Dělitelé: #{divisors}</td></tr>"
              openh = highlight opentext, word, pair[1], 'red'
              ciph = highlight ciphertext, word, pair[1], 'blue'
              temphtml += "<tr><td>#{ciph}</td></tr>"
              temphtml += "<tr><td>#{openh}</td></tr>"
          temphtml += "</table>"
          temphtml += "<p>Dále spočítáme index koincidence pro všechny délky klíče #{result.keylengths.join ', '}. Například pro délku klíče 4 bychom získali index koincidence takto:</p>"
          round_threshold = 1000000
          
          show_ioc = (klen) ->
            splitted = viglength.splitText ciphertext, klen
            iocs = splitted.map (text) -> friedman.ioc text
            iocs = iocs.map (num) -> _.round num, round_threshold
            temphtml += "<table class='with-border with-margin'>"
            temphtml += "<tr><th>Blok textu</th><th>Index koinc.</th></tr>"
            for i in [0...klen]
              temphtml += "<tr><td>#{splitted[i].slice 0, 42}&hellip;</td><td>#{iocs[i]}</td></tr>"
            temphtml += "</table>"
            temphtml += "<p>Průměrnou koincidenci vypočítáme jako aritmetický průměr všech #{klen} hodnot (to může být mírně nepřesné, ale výsledná chyba bude nevýznamná):</p><p>"
            temphtml += "(" + iocs.join(' + ') + ") / #{klen} = "
            temphtml += "<b>" + _.round(_.reduce(iocs, ((a, b) -> a + b)) / klen, round_threshold) + "</b></p>"
          show_ioc 4
          temphtml += "<p>A pro délku například 7:</p>"
          show_ioc 7

          temphtml += "<p>Následují indexy koincidence pro všechny uvažované délky. Zvýrazněná je ta délka, která má index koincidence nejbližší indexu koincidence českého jazyka (#{statistics.ioc}).</p>"
          temphtml += "<table class='with-border with-margin'>"
          temphtml += "<tr><th>Délka klíče</th><th>Index koincidence</th></tr>"
          result.indices.sort (a, b) -> a[1] - b[1]
          for pair in result.indices
            # console.log pair[1], result.keylen, pair[1] == result.keylen
            style = if pair[1] == result.keylen then "color: red; font-weight: bold;" else ""
            temphtml += "<tr style='#{style}'><td>#{pair[1]}</td><td>#{_.round pair[0], round_threshold}</td></tr>"
          temphtml += "</table>"

          temphtml += "<p>Dále už jen rozdělíme šifrový text do #{result.keylen} bloků a prolomíme <a href='./kryptoanalyza-vigenerovy-sifry'>standardním algoritmem pro prolomení šifry se znalostí klíče</a>.</p>"

          temphtml += "<table class='with-border with-margin'>"
          temphtml += "<tr><th>Bloky textu</th><th>Klíč</th></tr>"
          for line in result.blocks
            temphtml += "<tr><td>#{line[0]}&hellip;</td><td>#{line[1]}</td>"
          temphtml += "</table>"
          document.getElementById('crack-meta').innerHTML = temphtml
    false

router = 
  "caesarova-sifra": initCaesar
  "kryptoanalyza-caesarovy-sifry": initCrackCaesar
  "kryptoanalyza-caesarovy-sifry-2": initCrackCaesarDistance
  "vigenerova-sifra": initVigenere
  "kryptoanalyza-vigenerovy-sifry": initVigLength
  "kryptoanalyza-vigenerovy-sifry-2": initVigLengthGuess
  "kasiskeho-test": initVig3
  "friedmanuv-test": initFriedman

if typeof document != 'undefined'
  document.addEventListener 'DOMContentLoaded', ->
    key = document.body.id.replace('strana-', '')
    if router[key]
      router[key]()




















