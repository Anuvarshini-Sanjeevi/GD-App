const db = require('../models');
const ActivitySettings = db.ActivitySettings;

// Get settings for all activities
exports.findAll = async (req, res) => {
    try {
        const settings = await ActivitySettings.findAll();
        res.send(settings);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Get settings for a specific activity
exports.findOne = async (req, res) => {
    try {
        const settings = await ActivitySettings.findByPk(req.params.type);
        if (!settings) {
            return res.status(404).send({ message: "Settings not found for this activity type." });
        }
        res.send(settings);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Update settings for an activity
exports.update = async (req, res) => {
    try {
        const type = req.params.type;
        const [num] = await ActivitySettings.update(req.body, {
            where: { activity_type: type }
        });

        if (num == 1) {
            res.send({ message: "Settings updated successfully." });
        } else {
            res.send({ message: `Cannot update settings for type=${type}. Maybe activity was not found or req.body is empty!` });
        }
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
