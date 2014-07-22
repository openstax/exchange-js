# Javascript API for the Openstax Exchange service

## Client Examples

```coffee
exch = new Exchange(window.identToken)
page = exch.page('http://yahoo.com', 1)
page.heartbeat()
page.cursor('a[href="http://cnx.org"]', '', 0, 0)
page.mouseMove('a[href="http://cnx.org"]', 0, 0)
page.mouseClick('a[href="http://cnx.org"]', 0, 0)
page.input('input.answer', 'category', 'inputType', '42')
```

## Using NodeJS-style callbacks

```coffee
page.heartbeat (err, val) ->
  return console.error(err) if err
  console.log(val)
```

## Using promises

**Note:** To use Promises jQuery **must** be loaded before this file is.

```coffee
page.heartbeat()
.then -> console.log('Done')
```

## Create an Application token

```coffee
Exchange.Server.oAuth('u', 's')
.then (token) -> ...
```

## Create a new identifier

```coffee
server = new Exchange.Server(window.oAuthToken)
server.createIdent()
.then (ident) -> ...
```

## Get application events

Using NodeJS-style callbacks:

```coffee
server.events 'search string', {}, (err, results) ->
```

Using Promises (if jQuery is loaded):

```coffee
server.events('search string')
.then (results) -> console.log(results)
```
