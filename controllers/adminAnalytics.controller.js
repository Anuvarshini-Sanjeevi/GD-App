const db = require('../models');
const AdminAnalytics = db.AdminAnalytics;

exports.create = async (req, res) => {
    try {
        const analytics = await AdminAnalytics.create(req.body);
        res.status(201).send(analytics);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findByActivityType = async (req, res) => {
    try {
        const type = req.params.type;
        const analytics = await AdminAnalytics.findAll({
            where: { analytic_type: type }
        });
        res.send(analytics);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findAll = async (req, res) => {
    try {
        const { type, session_id } = req.query;
        const condition = {};
        if (type) condition.analytic_type = type;
        if (session_id) condition.session_id = session_id;

        const analytics = await AdminAnalytics.findAll({ where: condition });
        res.send(analytics);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findOne = async (req, res) => {
    try {
        const analytics = await AdminAnalytics.findByPk(req.params.id);
        if (!analytics) return res.status(404).send({ message: "Analytics not found" });
        res.send(analytics);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Start ID 88 - Analytics are typically read-only or appended, but adding full CRUD for admin
exports.update = async (req, res) => {
    try {
        const [num] = await AdminAnalytics.update(req.body, { where: { analytic_id: req.params.id } });
        if (num == 1) res.send({ message: "Analytics updated successfully." });
        else res.send({ message: "Cannot update Analytics." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.delete = async (req, res) => {
    try {
        const num = await AdminAnalytics.destroy({ where: { analytic_id: req.params.id } });
        if (num == 1) res.send({ message: "Analytics deleted successfully!" });
        else res.send({ message: "Cannot delete Analytics." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
