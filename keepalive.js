var https = require('https'); //importing http
var url = 'https://www.guardthis.info'
https.get(url, function(res) {
  res.on('data', function(chunk) {
    console.log('requested ' + url)
  });
}).on('error', function(err) {
  console.log("Error: " + err.message);
});