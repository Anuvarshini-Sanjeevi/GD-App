const db = require('../models');
const SessionConfig = db.SessionConfig;

exports.create = async (req, res) => {
    try {
        const { activity_type } = req.body;
        let finalConfig = { ...req.body };

        if (activity_type) {
            const settings = await db.ActivitySettings.findByPk(activity_type);
            if (settings) {
                // Apply defaults from ActivitySettings if not explicitly provided
                const defaults = {
                    advancement_pts: settings.advancement_pts,
                    max_capacity: settings.max_capacity,
                    time_limit_min: settings.time_limit_min,
                    cool_down_sec: settings.cool_down_sec,
                    weight_technical: settings.weight_technical,
                    weight_communication: settings.weight_communication,
                    weight_synergy: settings.weight_synergy,
                    auto_rewards: settings.auto_rewards,
                    intel_feedback: settings.intel_feedback,
                    activity_duration_minutes: settings.time_limit_min // Map time_limit to duration
                };

                for (const key in defaults) {
                    if (finalConfig[key] === undefined) {
                        finalConfig[key] = defaults[key];
                    }
                }
            }
        }

        const config = await SessionConfig.create(finalConfig);
        res.status(201).send(config);
    } catch (error) {
        console.error('Create SessionConfig Error:', error);
        res.status(500).send({ message: error.message });
    }
};

exports.findAll = async (req, res) => {
    try {
        const configs = await SessionConfig.findAll();
        res.send(configs);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findOne = async (req, res) => {
    try {
        const config = await SessionConfig.findByPk(req.params.id);
        if (!config) return res.status(404).send({ message: "Config not found" });
        res.send(config);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.update = async (req, res) => {
    try {
        const [num] = await SessionConfig.update(req.body, { where: { config_id: req.params.id } });
        if (num == 1) res.send({ message: "Config updated successfully." });
        else res.send({ message: "Cannot update Config." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.delete = async (req, res) => {
    try {
        const num = await SessionConfig.destroy({ where: { config_id: req.params.id } });
        if (num == 1) res.send({ message: "Config deleted successfully!" });
        else res.send({ message: "Cannot delete Config." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
exports.findActive = async (req, res) => {
    try {
        const configs = await SessionConfig.findAll({
            where: { status: 'ACTIVE' }
        });
        res.send(configs);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
