const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Ensure req.body is at least an empty object to prevent crashes
app.use((req, res, next) => {
    if (!req.body) {
        req.body = {};
    }
    next();
});

// Simple route for testing
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to the GD-Premium Backend API.' });
});

const authRoutes = require('./routes/auth.routes');
app.use('/auth', authRoutes);

// Student Activities Routes
const studentActivityRoutes = require('./routes/studentActivity.routes');
app.use('/api/student/activities', studentActivityRoutes);

// Admin Routes
const adminRoutes = require('./routes/admin.routes');
app.use('/api/admins', adminRoutes);

// User Routes
const userRoutes = require('./routes/user.routes');
app.use('/api/users', userRoutes);

// Hall QR Tokens Routes
const hallQrTokenRoutes = require('./routes/hallQrToken.routes');
app.use('/api/hall-qr-tokens', hallQrTokenRoutes);

// Session Configs Routes
const sessionConfigRoutes = require('./routes/sessionConfig.routes');
app.use('/api/session-configs', sessionConfigRoutes);

// Question Bank Routes
const questionBankRoutes = require('./routes/questionBank.routes');
app.use('/api/question-bank', questionBankRoutes);

// Admin Analytics Routes
const adminAnalyticsRoutes = require('./routes/adminAnalytics.routes');
app.use('/api/admin-analytics', adminAnalyticsRoutes);

// Admin Activity Log Routes
const adminActivityLogRoutes = require('./routes/adminActivityLog.routes');
app.use('/api/admin-activity-logs', adminActivityLogRoutes);

// Activity Settings Routes
const activitySettingsRoutes = require('./routes/activitySettings.routes');
app.use('/api/activity-settings', activitySettingsRoutes);



module.exports = app;
