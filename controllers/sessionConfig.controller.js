const db = require('../models');
const SessionConfig = db.SessionConfig;

exports.create = async (req, res) => {
    try {
        const config = await SessionConfig.create(req.body);
        res.status(201).send(config);
    } catch (error) {
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
