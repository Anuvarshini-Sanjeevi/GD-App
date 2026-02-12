const express = require('express');
const router = express.Router();
const studentActivityController = require('../controllers/studentActivity.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.get('/', authMiddleware, studentActivityController.getActivities);
router.post('/update', authMiddleware, studentActivityController.updateProgress);

module.exports = router;
