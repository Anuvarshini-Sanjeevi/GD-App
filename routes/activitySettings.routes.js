const express = require('express');
const router = express.Router();
const controller = require('../controllers/activitySettings.controller');

router.get('/', controller.findAll);
router.get('/:type', controller.findOne);
router.put('/:type', controller.update);

module.exports = router;
