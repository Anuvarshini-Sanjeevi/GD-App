const db = require('../models');
const HallQrToken = db.HallQrToken;

exports.create = async (req, res) => {
    try {
        const token = await HallQrToken.create(req.body);
        res.status(201).send(token);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findAll = async (req, res) => {
    try {
        const tokens = await HallQrToken.findAll();
        res.send(tokens);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findOne = async (req, res) => {
    try {
        const token = await HallQrToken.findByPk(req.params.id);
        if (!token) return res.status(404).send({ message: "Token not found" });
        res.send(token);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.update = async (req, res) => {
    try {
        const [num] = await HallQrToken.update(req.body, { where: { token_id: req.params.id } });
        if (num == 1) res.send({ message: "Token updated successfully." });
        else res.send({ message: "Cannot update Token." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.delete = async (req, res) => {
    try {
        const num = await HallQrToken.destroy({ where: { token_id: req.params.id } });
        if (num == 1) res.send({ message: "Token deleted successfully!" });
        else res.send({ message: "Cannot delete Token." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
