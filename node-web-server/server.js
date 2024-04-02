const http = require('http');
const url = require('url');
const querystring = require('querystring');
const fs = require('fs');

// Create a server object
const server = http.createServer((req, res) => {
    // Parse the URL
    const parsedUrl = url.parse(req.url);
    
    // Check if the request method is POST and the path is /receiveData
    if (req.method === 'GET' && parsedUrl.pathname === '/receiveData') {
        let body = '';
        
        // Receive data asynchronously
        req.on('data', (chunk) => {
            body += chunk.toString();
        });
        
        // When all data is received
        req.on('end', () => {
            // Parse the received data
            const postData = querystring.parse(body);
            
            // Log the received data
            console.log('Received data:', postData);
            
            // Write the received data to a file
            fs.appendFileSync('received_data.txt', JSON.stringify(postData) + '\n');
            
            // Send a response
            res.writeHead(200, { 'Content-Type': 'text/plain' });
            res.end('Data received successfully');
        });
    } else {
        // For any other requests, send a 404 Not Found response
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 Not Found');
    }
});

// Start the server
const port = 3000;
server.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}/`);
});
