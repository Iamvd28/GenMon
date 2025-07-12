const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors({ origin: true }));

app.get('/hello', (req, res) => {
  res.send('Hello from Firebase!');
});

exports.api = functions.https.onRequest(app);
