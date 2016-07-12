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

let $uri := uniq:random-uri("/path/prefix", ".ext")
return xdmp:document-insert($uri, <test/>)

let $uri-with-larger-precision := uniq:random-uri("/path/prefix", ".ext", 3)
return xdmp:document-insert($uri-with-larger-precision, <another-test/>)
```

## How it works

Many people (including myself) have asked for ways to generate sequential numbers in NoSQL solutions like MarkLogic. It is doable, but relatively slow. You will also end up with predictable IDs, which is considered bad practice from a security point of view. Instead it is better to pick random IDs. Doing so in a way that is guaranteed to give you a unique and unused ID is not particularly difficult with MarkLogic. Looking at the code though, you might wonder how it works.

First thing you need to understand is that code that runs in MarkLogic is always executed in a transactional way. If code runs in parallel, MarkLogic will ensure that no code can touch the same document at the same time. MarkLogic uses a sophisticated locking mechanism for that purpose. In-depth details about this mechanism can be found in the Inside MarkLogic whitepaper, that is available from DMC: https://developer.marklogic.com/inside-marklogic

The trick is to claim a lock on a document ID (a database uri in MarkLogic terms) before it exists. By claiming it, you will make sure no other running code can claim the same document ID. The `uniq:random-uri` function creates a new ID, and checks for its existance using `fn:exists(fn:doc($uri))`. That will create a so-called URI read lock. That is caused by the fact you attempt to access the actual document, instead just testing the existance through indexes with for instance `xdmp:exists`. That URI read lock will automatically remain in place until the current code completes. Even if multiple pieces of code are claiming a URI read lock for the same ID, all but the first will wait till the first completes, and may or may not have created a document with that ID. The first in row that notices the document doesn't exist, gets a chance at inserting a document with that ID. Subsequent ones will see a document with that uri exists, and will simply try again by `uniq:random-uri` calling itself again.

This strategy is also used by MarkLogic internally to create for instance users and roles in the Security database.
