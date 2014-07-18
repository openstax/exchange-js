# Javascript API for the Openstax Exchange service

## Client Examples

    exch = new Exchange(window.identToken)
    page = exch.page('http://yahoo.com', 1)
    page.heartbeat()
    page.cursor('a[href="http://cnx.org"]', '', 0, 0)
    page.mouseMove('a[href="http://cnx.org"]', 0, 0)
    page.mouseClick('a[href="http://cnx.org"]', 0, 0)
    page.input('input.answer', 'category', 'inputType', '42')

## Example with a callback

    page.heartbeat (err, val) ->
      return console.error(err) if err
      console.log(val)

## Example using promises

**Note:** jQuery **must** be loaded before this file is.

    page.heartbeat().then -> console.log('Done')

## Create an Application token

    Exchange.Server.oAuth('u', 's')

## Create a new identifier

    server = new Exchange.Server(window.oAuthToken)
    server.createIdent()

## Get application events

    server.events('yahoo')
