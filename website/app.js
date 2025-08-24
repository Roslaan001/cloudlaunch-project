const http = require('http');
const fs = require('fs');
const server = http.createServer((req, res) => {
  fs.readFile('index.html', (err, data) => {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end(data);
  });
});
server.listen(3000, () => console.log('Your server is running on port "3000"'));
