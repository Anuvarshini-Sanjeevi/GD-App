const db = require('../models');
const AdminActivityLog = db.AdminActivityLog;

exports.create = async (req, res) => {
    try {
        const log = await AdminActivityLog.create(req.body);
        res.status(201).send(log);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findAll = async (req, res) => {
    try {
        const logs = await AdminActivityLog.findAll();
        res.send(logs);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findOne = async (req, res) => {
    try {
        const log = await AdminActivityLog.findByPk(req.params.id);
        if (!log) return res.status(404).send({ message: "Log not found" });
        res.send(log);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.update = async (req, res) => {
    try {
        const [num] = await AdminActivityLog.update(req.body, { where: { log_id: req.params.id } });
        if (num == 1) res.send({ message: "Log updated successfully." });
        else res.send({ message: "Cannot update Log." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.delete = async (req, res) => {
    try {
        const num = await AdminActivityLog.destroy({ where: { log_id: req.params.id } });
        if (num == 1) res.send({ message: "Log deleted successfully!" });
        else res.send({ message: "Cannot delete Log." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
