xquery version "1.0-ml";

module namespace uniq = "http://marklogic.com/unique";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare function uniq:random-uri(
  $prefix as xs:string,
  $suffix as xs:string
)
  as xs:string
{
  let $uri := fn:concat($prefix, xdmp:random(), $suffix)
  return
    if (exists(doc($uri))) then
      uniq:random-uri($prefix, $suffix)
    else
      $uri
};
