const db = require('../models');
const QuestionBank = db.QuestionBank;

exports.create = async (req, res) => {
    try {
        const question = await QuestionBank.create(req.body);
        res.status(201).send(question);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findAll = async (req, res) => {
    try {
        const questions = await QuestionBank.findAll();
        res.send(questions);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.findOne = async (req, res) => {
    try {
        const question = await QuestionBank.findByPk(req.params.id);
        if (!question) return res.status(404).send({ message: "Question not found" });
        res.send(question);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.update = async (req, res) => {
    try {
        const [num] = await QuestionBank.update(req.body, { where: { question_id: req.params.id } });
        if (num == 1) res.send({ message: "Question updated successfully." });
        else res.send({ message: "Cannot update Question." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

exports.delete = async (req, res) => {
    try {
        const num = await QuestionBank.destroy({ where: { question_id: req.params.id } });
        if (num == 1) res.send({ message: "Question deleted successfully!" });
        else res.send({ message: "Cannot delete Question." });
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
