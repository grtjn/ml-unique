# ml-unique

MarkLogic library for generating unique database URIs and IDs 

## Install

Installation depends on the [MarkLogic Package Manager](https://github.com/joemfb/mlpm):

```
$ mlpm install ml-unique --save
$ mlpm deploy
```

## Usage

Example:

```xquery
xquery version "1.0-ml";

import module namespace uniq = "http://marklogic.com/unique" at "/ext/mlpm_modules/ml-unique/unique.xqy";

let $uri := uniq:random-uri("/path/prefix",".ext")
return xdmp:document-insert($uri, <test/>)
```
