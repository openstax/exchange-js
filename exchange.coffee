DEFAULT_ROOT_URL = 'http://localhost:3003'

# Simple jQuery.ajax() shim that returns a promise for a xhr object
ajax = window.jQuery?.ajax or (options, cb) ->

  # Use the browser XMLHttpRequest if it exists. If not, then this is NodeJS
  # Pull this in for every request so sepia.js has a chance to override `window.XMLHTTPRequest`
  if window?
    XMLHttpRequest = window.XMLHttpRequest
  else
    req = require
    XMLHttpRequest = req('xmlhttprequest').XMLHttpRequest

  xhr = new XMLHttpRequest()
  xhr.dataType = options.dataType
  xhr.overrideMimeType?(options.mimeType)
  xhr.open(options.type, options.url)

  if options.data and options.type isnt 'GET'
    xhr.setRequestHeader('Content-Type', options.contentType)

  for name, value of options.headers
    xhr.setRequestHeader(name, value)

  xhr.onreadystatechange = ->
    if 4 == xhr.readyState
      options.statusCode?[xhr.status]?()

      if xhr.status >= 200 and xhr.status < 300 or xhr.status is 304 or xhr.status is 302
        cb(null, JSON.parse(xhr.response))
      else
        cb(xhr)
  xhr.send(options.data)


# require('underscore-plus')
plus =
  camelize: (string) ->
    if string
      string.replace /[_-]+(\w)/g, (m) -> m[1].toUpperCase()
    else
      ''

  uncamelize: (string) ->
    return '' unless string
    return string.replace /([A-Z])+/g, (match, letter='') -> "_#{letter.toLowerCase()}"

  dasherize: (string) ->
    return '' unless string

    string = string[0].toLowerCase() + string[1..]
    string.replace /([A-Z])|(_)/g, (m, letter) ->
      if letter
        '-' + letter.toLowerCase()
      else
        '-'

uncamelizeObj = (obj) ->
  if Array.isArray(obj)
    return (uncamelizeObj(i) for i in obj)
  else if obj == Object(obj)
    o = {}
    for key, value of obj
      o[plus.uncamelize(key)] = uncamelizeObj(value)
    return o
  else
    return obj

_request = (args, config={}, method, path, data) ->
  cb = args[args.length - 1]

  rootUrl = config.rootUrl or DEFAULT_ROOT_URL
  # Prefix the path only when path is not an absolute URL
  path = "#{rootUrl}#{path}" if not /^https?:\/\//.test(path)

  headers = undefined
  if config.token
    headers =
      Authorization: "Bearer #{config.token}"

  uncamelizeObj(data) if data

  ajaxConfig =
    url: path
    type: method
    contentType: 'application/json'
    headers: headers
    processData: false # Don't convert to QueryString
    data: data and JSON.stringify(data) or null
    dataType: 'json'

  ajax ajaxConfig, (err, val) ->
    if err
      console.error(err)
    else
      console.log(val)
    cb?(err, val)


# Converts a dictionary to a query string.
# Internal helper method
toQueryString = (options) ->
  # Returns '' if `options` is empty so this string can always be appended to a URL
  return '' if not options or options is {}
  params = for key, value of options or {}
    "#{key}=#{encodeURIComponent(value)}" if value?
  return "?#{params.join('&')}" if params.length
  return ''



class Exchange
  constructor: (token, rootUrl) ->
    # Note: `rootUrl` is optional
    @config = {token, rootUrl}

  page: (resource, attempt, metadata='', occurredAt=null) ->
    new Page(@config, resource, attempt, metadata)


class Page
  constructor: (@config, @resource, @attempt, @metadata, @occurredAt) ->
  _combine: (opts={}) ->
    for key in ['resource', 'attempt', 'metadata']
      opts[key] = @[key]
    opts['occurred_at'] ?= @occurredAt
    opts
  navigate: (from, to) ->
    opts = @_combine {from, to}
    _request(arguments, @config, 'POST', '/api/events/identifiers/navigate', opts)
  cursor: (selector, action, xPosition, yPosition) ->
    opts = @_combine {selector, action, xPosition, yPosition}
    _request(arguments, @config, 'POST', '/api/events/identifiers/cursors', opts)
  mouseMove: (selector, xPosition, yPosition) ->
    opts = @_combine {selector, xPosition, yPosition}
    _request(arguments, @config, 'POST', '/api/events/identifiers/mouse_movements', opts)
  mouseClick: (selector, xPosition, yPosition) ->
    opts = @_combine {selector, xPosition, yPosition}
    _request(arguments, @config, 'POST', '/api/events/identifiers/mouse_clicks', opts)
  heartbeat: (selector, yPosition) ->
    opts = @_combine {selector, yPosition}
    _request(arguments, @config, 'POST', '/api/events/identifiers/heartbeats', opts)
  input: (selector, category, inputType, value) ->
    opts = @_combine {selector, category, inputType, value}
    _request(arguments, @config, 'POST', '/api/events/identifiers/inputs', opts)


# Should only be used from NodeJS (server or commandline)
Exchange.Server = class ExchangeServer

  constructor: (token, rootUrl) ->
    # Note: `rootUrl` is optional
    @config = {token, rootUrl}

  createIdent: ->
    # Store this as apiKey when successful
    _request(arguments, @config, 'POST', '/api/identifiers', null)

  events: (q, opts={}) ->
    opts.q ?= q if q
    _request(arguments, @config, 'GET', "/api/events#{toQueryString(opts)}", null)

# This should **not** be used by the browser; only on a server (NodeJS)
# and should ONLY BE CALLED ONCE. Subsequent calls result in bogus tokens
# because they are not added to the backend table.
ExchangeServer.oAuth = (id, secret, rootUrl) ->
  opts =
    grant_type: 'client_credentials'
    client_id: id
    client_secret: secret
  _request(arguments, {rootUrl}, 'POST', "/oauth/token#{toQueryString(opts)}", null)



module?.export = Exchange
window?.Exchange = Exchange
