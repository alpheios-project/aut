(:
  Copyright 2008-2009 Cantus Foundation
  http://alpheios.net

  This file is part of Alpheios.

  Alpheios is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Alpheios is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :)

(:
  XQuery to extract short definitions from Autenrieth Homeric Greek lexicon

  Output is in form
  <entrylist id="grc-aut">
    <entry id="$id">
      <lemma>$lemma</lemma>
      <meaning>$definition</meaning>
    </entry>
    ...
  </entrylist.
 :)

(: file global variables :)
declare variable $f_lang := "grc";
declare variable $f_code := "aut";
declare variable $f_docName := concat("/sgml/lexica/",
                                      $f_lang, "/",
                                      $f_code, "/uautenrieth.xml");
declare variable $f_entries := doc($f_docName)//entryFree;

declare function local:merge-glosses(
  $a_glosses as element()*,
  $a_data as xs:string) as xs:string*
{
  if (count($a_glosses) > 0)
  then
    let $t1 := normalize-space(concat($a_glosses[1], " or ", $a_glosses[2]))
    let $t2 := normalize-space(concat($a_glosses[1], ", or ", $a_glosses[2]))
    return
      if (contains($a_data, $t1))
      then
        (
          $t1,
          local:merge-glosses(subsequence($a_glosses, 3), $a_data)
        )
      else if (contains($a_data, $t2))
      then
        (
          $t2,
          local:merge-glosses(subsequence($a_glosses, 3), $a_data)
        )
      else
        (
          normalize-space($a_glosses[1]),
          local:merge-glosses(subsequence($a_glosses, 2), $a_data)
        )
  else ()
};

declare function local:get-meaning($a_entry as element()) as xs:string*
{
  let $meaning :=
    (: if glosses exist, use them :)
    if (exists($a_entry//gloss))
    then
        local:merge-glosses($a_entry//gloss, normalize-space(data($a_entry)))
    else
      let $text :=
        normalize-space(
          $a_entry/text()[string-length(normalize-space(.)) > 0][1])
      let $quote := normalize-space($a_entry/foreign[1])
      let $quote1 := 
        if (contains($quote, ","))
        then
          substring-before($quote, ",")
        else
          $quote
      return
        (: if this refers to another entry, use that entry's meaning :)
        if (    ($text = (": see", "="))
            and (string-length($quote1) > 0)
            and exists($f_entries[./@key = $quote1]))
        then
          local:get-meaning($f_entries[./@key = $quote1])
        (: otherwise, join text and quote :)
        else
          (: discard leading ": " :)
          let $text :=
            if (starts-with($text, ": "))
            then
              substring-after($text, ": ")
            else
              $text
          (: add quotation marks :)
          let $quote :=
            if (string-length($quote) > 0)
            then
              concat("“", $quote ,"”")
            else ()

          return
            string-join(($text, $quote), " ")

  for $text in $meaning
  let $textlen := string-length($text)
  return
    if (contains(",:;.", substring($text, $textlen)))
    then
      substring($text, 1, $textlen - 1)
    else
      $text
};

(: corrections :)
let $corrections :=
  <corrections>
    <entry>
      <lemma>ἆ</lemma>
      <meaning>interjection expressive of pity or horror, freq. w. voc. of “δειλός”</meaning>
    </entry>
    <entry>
      <lemma>Αἴγισθος</lemma>
      <meaning>son of Thyestes, and cousin of Agamemnon</meaning>
    </entry>
    <entry>
      <lemma>Ἀμφιάραος</lemma>
      <meaning>a seer and warrior of Argos, son of Oecles, great grandson of the seer Melampus</meaning>
    </entry>
    <entry>
      <lemma>ἔδαφος</lemma>
      <meaning>floor of a ship</meaning>
    </entry>
    <entry>
      <lemma>Ζέλεια</lemma>
      <meaning>a town at the foot of Mt. Ida</meaning>
    </entry>
    <entry>
      <lemma>ιμάς</lemma>
      <meaning>strap or thong; straps; reins; halter; chin-strap; cestus; leash or latchstring</meaning>
    </entry>
    <entry>
      <lemma>Φυλεύς</lemma>
      <meaning>son of Augēas of Elis</meaning>
    </entry>
    <entry>
      <lemma>ωὑτός</lemma>
      <meaning>the same</meaning>
    </entry>
    <entry>
      <lemma>ἀνιάω</lemma>
      <meaning>be a torment, nuisance</meaning>
    </entry>
    <entry>
      <lemma>οὐδός2</lemma>
      <meaning>way, path, road, journey</meaning>
    </entry>
    <entry>
      <lemma>ἕ</lemma>
      <meaning>him, her</meaning>
    </entry>
    <entry>
      <lemma>ὅστε</lemma>
      <meaning>who, which</meaning>
    </entry>
    <entry>
      <lemma>δέ1</lemma>
      <meaning>but, and</meaning>
    </entry>
    <entry>
      <lemma>εἰμί1</lemma>
      <meaning>to be; exist, be possible</meaning>
    </entry>
    <entry>
      <lemma>αὐτός</lemma>
      <meaning>same, self</meaning>
    </entry>
    <entry>
      <lemma>ὅς1</lemma>
      <meaning>he, this, that; who, that, which</meaning>
    </entry>
    <entry>
      <lemma>μέν</lemma>
      <meaning>in truth, indeed, certainly; to be sure</meaning>
    </entry>
    <entry>
      <lemma>ἀλλά</lemma>
      <meaning>but, nay but, but yet, yet</meaning>
    </entry>
    <entry>
      <lemma>ἀνά</lemma>
      <meaning>up; up! quick!; up there, thereon; back, 'hold up'; up on, upon; up to, up through</meaning>
    </entry>
    <entry>
      <lemma>ὅστις</lemma>
      <meaning>who(so)ever, which(so)ever, what(so)ever</meaning>
    </entry>
    <entry>
      <lemma>ἤ</lemma>
      <meaning>or, than, whether; either . . or</meaning>
    </entry>
    <entry>
      <lemma>μή</lemma>
      <meaning>not, lest</meaning>
    </entry>
    <entry>
      <lemma>οὖν</lemma>
      <meaning>now, then; if, 'for that matter'</meaning>
    </entry>
    <entry>
      <lemma>διά</lemma>
      <meaning>between, through</meaning>
    </entry>
    <entry>
      <lemma>ἐμός</lemma>
      <meaning>my, mine (also possessive pronoun)</meaning>
    </entry>
    <entry>
      <lemma>ἡμέτερος</lemma>
      <meaning>our, ours (also possessive pronoun)</meaning>
    </entry>
    <entry>
      <lemma>σός</lemma>
      <meaning>thy, thine (also possessive pronoun)</meaning>
    </entry>
    <entry>
      <lemma>ὑμέτερος</lemma>
      <meaning>your, yours (also possessive pronoun)</meaning>
    </entry>
    <entry>
      <lemma>σφέτερος</lemma>
      <meaning>their (also possessive pronoun)</meaning>
    </entry>
(:
    <entry>
      <lemma></lemma>
      <meaning></meaning>
    </entry>
 :)
  </corrections>
let $correctedLemmas := $corrections/entry/lemma/text()

return
(: wrap everything in <entrylist> :)
element entrylist
{
  attribute id { concat($f_lang, "-", $f_code) },

  (: for each entry in file :)
  for $entry in $f_entries
  let $lemma := data($entry/@key)
  let $meaning := 
    local:get-meaning(
      (: if correction exists, use it :)
      if ($lemma = $correctedLemmas)
      then
        $corrections/entry[./lemma = $lemma]/meaning
      else
        $entry
    )

  (: put out entry :)
  return
    element entry
    {
      $entry/@id,
      element lemma { $lemma },
      if (count($meaning) > 0)
      then
        element meaning { string-join($meaning, "; ") }
      else ()
    },

  (: additions :)
  ()
}
