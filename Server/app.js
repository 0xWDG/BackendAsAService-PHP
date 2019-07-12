/**
 * Class 'Server'
 * Backend as a Service Server (BaaS Server)
 *
 * @version 1.0
 * @copyright Wesley de Groot (https://wesleydegroot.nl), et al.
 * @link https://github.com/wdg/BaaS
 * @url https://github.com/wdg/BaaS
 * @package BaaS
 */

var http = require('http')

// create a server object
http.createServer(handleHTTPRequest).listen(8080) // the server object listens on port 8080

function handleHTTPRequest (request, response) {
  var responseArray = {}

  switch (request.url.split('/')[1]) {
  	case 'row.create':
  		responseArray = rowActions('create', request)
      break

  		default:
      	responseArray = {
      		'request': request.url,
      		'error': 'Cannot parse request'
      	}
  }

  if (typeof responseArray === 'object') {
  	response.writeHead(200, {'Content-Type': 'application/json'})
  	responseArray.info = '[BaaS] Node.js Beta.'
  	response.write(JSON.stringify(responseArray))
  } else {
    response.writeHead(200, {'Content-Type': 'text/html'})
    response.write(responseArray)
  }

  response.end()
}

function rowActions (action, r) {
  return {
  	'request': r.url,
  	'action': action
  }
}

function userLogin (req, res) { }
