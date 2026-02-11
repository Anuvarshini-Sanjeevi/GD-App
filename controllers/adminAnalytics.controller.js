const db = require('../models');
const StudentRanking = db.StudentRanking;
const AdminAnalytics = db.AdminAnalytics; // Keep if needed for other things, but table is dropped. 
// Actually, since table is dropped, we should remove AdminAnalytics usage.

exports.getRankings = async (req, res) => {
    try {
        const { activity, level } = req.query;
        const where = {};

        // Default to GROUP_DISCUSSION if not specified? Or return all? 
        // User asked for "if i click group discussion overall ranks need to be shown"
        // Let's filter if provided.
        if (activity) where.activity_type = activity;
        if (level) where.level = level;

        const rankings = await StudentRanking.findAll({
            where: where,
            order: [
                ['points', 'DESC'],
                ['rank', 'ASC']
            ]
        });

        res.send(rankings);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Keeping these for now but they might be broken if they rely on AdminAnalytics
// Since we dropped AdminAnalytics, these will definitely fail if called.
// I will comment them out or remove them to avoid confusion, 
// but sticking to "getRankings" as the primary new feature.
// The user "delete the existing table ... and create new table" -> implies we replace functionality.

exports.create = async (req, res) => {
    res.status(501).send({ message: "Legacy AdminAnalytics is deprecated." });
};

exports.findByActivityType = async (req, res) => {
    res.status(501).send({ message: "Legacy AdminAnalytics is deprecated." });
};

exports.findAll = async (req, res) => {
    res.status(501).send({ message: "Legacy AdminAnalytics is deprecated." });
};

exports.findOne = async (req, res) => {
    res.status(501).send({ message: "Legacy AdminAnalytics is deprecated." });
};

exports.update = async (req, res) => {
    res.status(501).send({ message: "Legacy AdminAnalytics is deprecated." });
};

exports.delete = async (req, res) => {
    res.status(501).send({ message: "Legacy AdminAnalytics is deprecated." });
};

