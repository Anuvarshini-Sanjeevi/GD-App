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
        // Only process if we have necessary time fields
        if (session.started_at && session.status !== 'CANCELLED') {
            const now = new Date();
            const currentTime = now.getTime();
            const startTime = new Date(session.started_at).getTime();

            // Get duration and join window (default to 5 mins if not set)
            const durationMinutes = parseFloat(session.activity_duration_minutes) || 0;
            const joinWindowMinutes = parseFloat(session.join_window_minutes) || 5;

            const joinWindowMs = joinWindowMinutes * 60 * 1000;
            const durationMs = durationMinutes * 60 * 1000;

            const timeSinceStart = currentTime - startTime;

            let newStatus = session.status;

            // Logic:
            // 0 <= time < joinWindow: ACTIVE (Join Window)
            // joinWindow <= time < (joinWindow + duration): IN_PROGRESS
            // time >= (joinWindow + duration): COMPLETED (if auto-complete/expire enabled)

            if (timeSinceStart < 0) {
                // Future start time
                newStatus = 'WAITING';
            } else if (timeSinceStart < joinWindowMs) {
                // In Join Window
                newStatus = 'ACTIVE';
            } else if (timeSinceStart < (joinWindowMs + durationMs)) {
                // Join window over, activity in progress
                newStatus = 'IN_PROGRESS';
            } else {
                // Activity time over
                newStatus = 'COMPLETED';
            }

            // Only update if status changed and it's a valid transition (e.g. don't go back from COMPLETED to ACTIVE)
            if (newStatus !== session.status) {
                // Update the session object (in memory for now, caller decides to save)
                // For findAll/findOne we just return the calculated status for display
                const sessionData = session.toJSON ? session.toJSON() : { ...session };
                return { ...sessionData, status: newStatus };
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
