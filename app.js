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

// Admin Routes
const adminRoutes = require('./routes/admin.routes');
app.use('/api/admins', adminRoutes);

const userRoutes = require('./routes/user.routes');
app.use('/api/users', userRoutes);

const hallQrTokenRoutes = require('./routes/hallQrToken.routes');
app.use('/api/hall-qr-tokens', hallQrTokenRoutes);

const sessionConfigRoutes = require('./routes/sessionConfig.routes');
app.use('/api/session-configs', sessionConfigRoutes);

const questionBankRoutes = require('./routes/questionBank.routes');
app.use('/api/question-bank', questionBankRoutes);

const adminAnalyticsRoutes = require('./routes/adminAnalytics.routes');
app.use('/api/admin-analytics', adminAnalyticsRoutes);

const adminActivityLogRoutes = require('./routes/adminActivityLog.routes');
app.use('/api/admin-activity-logs', adminActivityLogRoutes);

module.exports = app;
