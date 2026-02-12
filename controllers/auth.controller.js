const { User, StudentRanking } = require('../models');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

exports.register = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        // Check if user already exists
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            return res.status(400).json({ message: 'Email already in use.' });
        }

        // Create new user (password hashing handled by hooks)
        const newUser = await User.create({
            name,
            email,
            password,
            role: role || 'student'
        });

        res.status(201).json({
            message: 'User registered successfully.',
            user: {
                id: newUser.user_id,
                name: newUser.name,
                email: newUser.email,
                role: newUser.role
            }
        });

    } catch (error) {
        console.error('Registration Error:', error);
        res.status(500).json({ message: 'Server error during registration.' });
    }
};

exports.login = async (req, res) => {
    try {
        if (!req.body || Object.keys(req.body).length === 0) {
            return res.status(400).json({ message: 'Request body is missing or empty. Ensure Content-Type is application/json.' });
        }

        const { email, username, password } = req.body;
        const loginIdentifier = email || username;

        if (!loginIdentifier) {
            return res.status(400).json({ message: 'Email or username is required.' });
        }

        // Find user
        const user = await User.findOne({ where: { email: loginIdentifier } });
        if (!user) {
            return res.status(401).json({ message: 'Invalid credentials.' });
        }

        // Verify password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials.' });
        }

        // Generate token
        const token = jwt.sign(
            { id: user.user_id, role: user.role },
            JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            message: 'Login successful.',
            token,
            user: {
                id: user.user_id,
                name: user.name,
                email: user.email,
                role: user.role,
                level: user.current_level
            }
        });

    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Server error during login.' });
    }
};
exports.getProfile = async (req, res) => {
    try {
        const user = await User.findByPk(req.user.id, {
            attributes: { exclude: ['password'] }
        });

        if (!user) {
            return res.status(404).json({ message: 'User not found.' });
        }

        let profileData = user.toJSON();

        // If user is a student, fetch their rank from StudentRankings
        if (user.role === 'student') {
            const ranking = await StudentRanking.findOne({
                where: {
                    student_id: user.user_id,
                    activity_type: 'GROUP_DISCUSSION', // Default per UI
                    level: 'OVERALL'
                },
                attributes: ['rank']
            });
            profileData.rank = ranking ? ranking.rank : null;
        }

        res.json(profileData);
    } catch (error) {
        console.error('Get Profile Error:', error);
        res.status(500).json({ message: 'Server error while fetching profile.' });
    }
};
