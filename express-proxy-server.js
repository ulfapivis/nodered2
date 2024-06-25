const express = require('express');
const helmet = require('helmet');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();

// app.set('trust proxy', 1); // This will trust the reverse proxy's IP address
app.set('trust proxy', true);
app.use(helmet());
app.use(cors());

// Define your Content Security Policy
const csp = {
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'", "data:", "filesystem:", "blob:"],
    scriptSrcAttr: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", "data:", "http:", "https:"],
    mediaSrc: ["'self'"],
    connectSrc: ["'self'", "https://catalogue.nodered.org"],
    frameAncestors: ["'self'"],
  }
};

app.use(helmet.contentSecurityPolicy(csp));

const allowedIps = process.env.ALLOWED_IPS
//.split(',');

// Middleware to check if the request is from an allowed IP
// app.use((req, res, next) => {
//     let ips = req.headers['x-forwarded-for'] ? req.headers['x-forwarded-for'].split(',') : [req.socket.remoteAddress];
//     ips = ips.map(ip => ip.trim()); // Trim whitespace from each IP
//     console.log(`Incoming request from IPs: ${ips.join(', ')}`);
    
//     const allowed = ips.some(ip => allowedIps.includes(ip));
    
//     if (allowed) {
//       console.log(`At least one IP in ${ips.join(', ')} is allowed`);
//       next();
//     } else {
//       console.log(`None of the IPs in ${ips.join(', ')} are allowed`);
//       res.status(403).send('Forbidden');
//     }
// });

app.use((req, res, next) => {
  // Extract the IP address
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  console.log(`Incoming request from IP: ${ip}`);
  
  // Check if the request is from an allowed IP
  if (allowedIps.includes(ip)) {
    console.log(`IP ${ip} is allowed`);
    req.allowedIp = true;  // Add a new property to the request
    next();
  } else {
    console.log(`IP ${ip} is not allowed`);
    req.allowedIp = false;  // Add a new property to the request
    res.status(403).send('Forbidden');
  }
});

app.use('/', createProxyMiddleware({ 
  target: 'http://node-red:1880',
  changeOrigin: true,
  ws: true,
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(500).send('node-red proxy error.');
  },
}));

app.listen(8080, () => {
  console.log('Express server listening on port 8080');
});