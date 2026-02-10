const db = require('../models');
const User = db.User;

// Create User
exports.create = async (req, res) => {
    try {
        // Password hashing is handled by model hooks
        const user = await User.create(req.body);
        // Remove password from response
        const userResponse = user.toJSON();
        delete userResponse.password;

        res.status(201).send(userResponse);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Get All Users
exports.findAll = async (req, res) => {
    try {
        const users = await User.findAll({
            attributes: { exclude: ['password'] }
        });
        res.send(users);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Get One User
exports.findOne = async (req, res) => {
    try {
        const user = await User.findByPk(req.params.id, {
            attributes: { exclude: ['password'] }
        });
        if (!user) return res.status(404).send({ message: "User not found" });
        res.send(user);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Update User
exports.update = async (req, res) => {
    try {
        const id = req.params.id;
        // Password hashing is handled by model hooks if password is changed
        const [num] = await User.update(req.body, { where: { user_id: id }, individualHooks: true });

        if (num == 1) {
            res.send({ message: "User was updated successfully." });
        } else {
            res.send({ message: `Cannot update User with id=${id}. Maybe User was not found or req.body is empty!` });
        }
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};

// Delete User
exports.delete = async (req, res) => {
    try {
        const id = req.params.id;
        const num = await User.destroy({ where: { user_id: id } });
        if (num == 1) {
            res.send({ message: "User was deleted successfully!" });
        } else {
            res.send({ message: `Cannot delete User with id=${id}. Maybe User was not found!` });
        }
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
};
