// app.js
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.status(200).send('Hello, World is ready');
});

app.get('/user/:id', (req, res) => {
  res.status(200).json({ id: req.params.id });
});

module.exports = app;