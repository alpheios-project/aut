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
  XQuery to add ids to entries in Autenrieth Homeric Greek lexicon
 :)

(: file global variables :)
declare variable $f_doc := doc("/sgml/lexica/grc/aut/autenrieth.xml");
declare variable $f_keys := $f_doc//entryFree/@key;

declare function local:copy(
  $a_element as element()) as element()
{
  element {node-name($a_element)}
  {
    (: if this is an entry, add id attribute :)
    if (string(node-name($a_element)) = "entryFree")
    then
      attribute id
      {
        concat('n', index-of($f_keys, $a_element/@key) - 1)
      }
    else (),

    (: copy attributes, but not TEI additions :)
    for $attr in $a_element/@*
    let $attr-name := string(node-name($attr))
    return
      if (not($attr-name = ("TEIform", "opt", "default")))
      then
        $attr
      else (),

    (: recurse :)
    for $child at $i in $a_element/node()
    return
      if ($child instance of element())
      then
        local:copy($child)
      else
        $child
  }
};

local:copy($f_doc/*)
