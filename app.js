const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Simple route for testing
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to the GD-Premium Backend API.' });
});

const authRoutes = require('./routes/auth.routes');
app.use('/auth', authRoutes);

module.exports = app;
