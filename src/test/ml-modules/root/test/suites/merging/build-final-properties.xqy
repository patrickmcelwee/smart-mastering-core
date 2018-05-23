xquery version "1.0-ml";

import module namespace const = "http://marklogic.com/smart-mastering/constants"
  at "/ext/com.marklogic.smart-mastering/constants.xqy";
import module namespace merging = "http://marklogic.com/smart-mastering/merging"
  at "/ext/com.marklogic.smart-mastering/merging.xqy";
import module namespace merging-impl = "http://marklogic.com/smart-mastering/survivorship/merging"
  at "/ext/com.marklogic.smart-mastering/survivorship/merging/base.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";
import module namespace lib = "http://marklogic.com/smart-mastering/test" at "lib/lib.xqy";

declare namespace map = "http://marklogic.com/xdmp/map";

declare option xdmp:mapping "false";

declare function local:all-true($seq as xs:boolean*) as xs:boolean
{
  fn:fold-left(function($z, $a) { $z and $a }, fn:true(), ($seq))
};

let $uris := map:keys($lib:TEST-DATA)
let $docs := $uris ! fn:doc(.)
let $merge-options := merging:get-options($lib:OPTIONS-NAME, $const:FORMAT-XML)
let $sources := merging-impl:get-sources($docs)
let $actual := merging-impl:build-final-properties(
  $merge-options,
  merging-impl:get-instances($docs),
  $docs,
  $sources
)

(: The revenue property is in only one of the documents. Make sure the attributed source is correct. :)
let $revenue-map :=
  for $map in $actual
  where map:contains(-$map, "Revenues")
  return $map
(: Both docs have the same value for the CaseAmount property. :)
let $case-amount-map :=
  for $map in $actual
  where map:contains(-$map, "CaseAmount")
  return $map
(: The docs have different values for the id property. :)
let $id-maps :=
  for $map in $actual
  where map:contains(-$map, "id")
  return $map
return (
  test:assert-exists($revenue-map),
  test:assert-equal(1, fn:count(map:get($revenue-map, "sources"))),
  test:assert-equal(text{ "SOURCE2" }, map:get($revenue-map, "sources")/name),

  test:assert-exists($case-amount-map),
  test:assert-equal(2, fn:count(map:get($case-amount-map, "sources"))),
  test:assert-equal(<CaseAmount>1287.9</CaseAmount>, map:get($case-amount-map, "values")),

  test:assert-equal(2, fn:count($id-maps)),
  test:assert-true(
    let $map := $id-maps[1]
    let $truths := (
      (map:get($map, "sources")/name = text{"SOURCE1"} and fn:deep-equal(map:get($map, "values"), <id>6986792174</id>)) or
      (map:get($map, "sources")/name = text{"SOURCE2"} and fn:deep-equal(map:get($map, "values"), <id>6270654339</id>))
    )
    return  local:all-true($truths)
  )
)
