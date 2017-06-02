xquery version "1.0-ml";

module namespace uniq = "http://marklogic.com/unique";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $used-uris := map:map();

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
