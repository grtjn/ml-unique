xquery version "1.0-ml";

module namespace uniq = "http://marklogic.com/unique";

declare default function namespace "http://www.w3.org/2005/xpath-functions"; (::)

declare option xdmp:mapping "false";
declare option xdmp:update "true";

declare variable $used-uris := map:map();
declare variable $counter-base-uri := "/counters/";

(: fast-random-uri does not apply locks, and is therefor
   much faster than other methods. 
:)
declare function uniq:fast-random-uri(
  $prefix as xs:string,
  $suffix as xs:string
) {
  let $random := sem:uuid-string()
  return concat($prefix, $random, $suffix)
};

declare function uniq:random-uri(
  $prefix as xs:string,
  $suffix as xs:string
)
  as xs:string
{
  uniq:random-uri($prefix, $suffix, 1)
};

declare function uniq:random-uri(
  $prefix as xs:string,
  $suffix as xs:string,
  $precision as xs:integer
)
  as xs:string
{
  let $random :=
    if ($precision gt 1) then
      string-join(
        for $i in (1 to $precision)
        return xs:string(xdmp:random()),
        '-'
      )
    else
      xdmp:random()
  let $uri := concat($prefix, $random, $suffix)
  return
    if (map:get($used-uris, $uri) or exists(doc($uri))) then
      uniq:random-uri($prefix, $suffix, $precision + 1)
    else
      let $_ := map:put($used-uris, $uri, true())
      return
        $uri
};

declare function uniq:next-sequential-uri(
  $prefix as xs:string,
  $suffix as xs:string,
  $counter-space as xs:string
) as xs:unsignedLong
{
  let $uri := $counter-base-uri || $counter-space || ".xml"
  let $next-id :=
    xdmp:invoke-function(
      function () {
        let $_ := xdmp:lock-for-update($uri)
        let $doc := fn:doc($uri)
        let $next :=
          ($doc/LastId/xs:unsignedLong(.), 0)[1] + 1
        let $_ :=
          xdmp:document-insert($uri, <LastId>{$next}</LastId>, xdmp:default-permissions(), "counters")
        return $next
      },
      <options xmlns="xdmp:eval">
        <transaction-mode>update-auto-commit</transaction-mode>
        <isolation>different-transaction</isolation>
      </options>
    )
  return concat($prefix, $next-id, $suffix)
};
