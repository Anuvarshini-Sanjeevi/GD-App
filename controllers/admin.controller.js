const db = require('../models');
const Admin = db.Admin;
const bcrypt = require('bcryptjs');

// Create Admin
exports.create = async (req, res) => {
    try {
        const admin = await Admin.create(req.body);
        res.status(201).send(admin);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Get All Admins
exports.findAll = async (req, res) => {
    try {
        const admins = await Admin.findAll();
        res.send(admins);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Get One Admin
exports.findOne = async (req, res) => {
    try {
        const admin = await Admin.findByPk(req.params.id);
        if (!admin) return res.status(404).send({ message: "Admin not found" });
        res.send(admin);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Update Admin
exports.update = async (req, res) => {
    try {
        const id = req.params.id;
        const [num] = await Admin.update(req.body, { where: { admin_id: id } });
        if (num == 1) {
            res.send({ message: "Admin was updated successfully." });
        } else {
            res.send({ message: `Cannot update Admin with id=${id}. Maybe Admin was not found or req.body is empty!` });
        }
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Delete Admin
exports.delete = async (req, res) => {
    try {
        const id = req.params.id;
        const num = await Admin.destroy({ where: { admin_id: id } });
        if (num == 1) {
            res.send({ message: "Admin was deleted successfully!" });
        } else {
            res.send({ message: `Cannot delete Admin with id=${id}. Maybe Admin was not found!` });
        }
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
