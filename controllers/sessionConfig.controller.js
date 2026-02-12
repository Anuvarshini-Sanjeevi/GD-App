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
                    team_size_max: settings.max_capacity, // Correct mapping
                    activity_duration_minutes: settings.time_limit_min, // Correct mapping
                    cool_down_sec: settings.cool_down_sec,
                    weight_technical: settings.weight_technical,
                    weight_communication: settings.weight_communication,
                    weight_synergy: settings.weight_synergy,
                    auto_rewards: settings.auto_rewards,
                    intel_feedback: settings.intel_feedback
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

const checkSessionExpiration = (session) => {
    try {
        if (session.status === 'ACTIVE' && session.started_at && (session.activity_duration_minutes !== null && session.activity_duration_minutes !== undefined)) {
            const startTime = new Date(session.started_at).getTime();
            const currentTime = new Date().getTime();
            const durationMinutes = parseFloat(session.activity_duration_minutes);
            const durationMs = durationMinutes * 60 * 1000;

            const diff = currentTime - startTime;

            if (diff >= durationMs) {
                // Return a copy with status set to INACTIVE
                const sessionData = session.toJSON ? session.toJSON() : { ...session };
                return { ...sessionData, status: 'INACTIVE' };
            }
        }
    } catch (e) {
        console.error('Error in checkSessionExpiration:', e);
    }
    return session;
};

exports.findAll = async (req, res) => {
    try {
        const configs = await SessionConfig.findAll();
        const processedConfigs = configs.map(config => checkSessionExpiration(config));
        res.send(processedConfigs);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findOne = async (req, res) => {
    try {
        const config = await SessionConfig.findByPk(req.params.id);
        if (!config) return res.status(404).send({ message: "Config not found" });
        res.send(checkSessionExpiration(config));
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.update = async (req, res) => {
    try {
        const updateData = { ...req.body };

        // If status is being updated to ACTIVE, set started_at if not already set
        if (updateData.status === 'ACTIVE') {
            const currentConfig = await SessionConfig.findByPk(req.params.id);
            console.log('Updating to ACTIVE. CurrentConfig status:', currentConfig ? currentConfig.status : 'None');
            if (currentConfig && currentConfig.status !== 'ACTIVE') {
                updateData.started_at = new Date();
                console.log('Set started_at to:', updateData.started_at);
            }
        }

        const [num] = await SessionConfig.update(updateData, { where: { config_id: req.params.id } });
        if (num == 1) res.send({ message: "Config updated successfully.", started_at: updateData.started_at });
        else res.send({ message: "Cannot update Config." });
    } catch (error) {
        console.error('Update Error:', error);
        res.status(500).send({ message: error.message });
    }
};

exports.delete = async (req, res) => {
    try {
        const num = await SessionConfig.destroy({ where: { config_id: req.params.id } });
        if (num == 1) res.send({ message: "Config deleted successfully!" });
        else res.send({ message: "Cannot delete Token." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findActive = async (req, res) => {
    try {
        const configs = await SessionConfig.findAll({
            where: { status: 'ACTIVE' }
        });

        const processedConfigs = configs
            .map(config => checkSessionExpiration(config))
            .filter(config => config.status === 'ACTIVE'); // Still active

        res.send(processedConfigs);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
