'use strict';
const bcrypt = require('bcryptjs');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const salt = await bcrypt.genSalt(8);
        const hashedPassword = await bcrypt.hash('password123', salt);

        return queryInterface.bulkInsert('Users', [{
            name: 'Supervisor User',
            email: 'supervisor@example.com',
            password: hashedPassword,
            role: 'supervisor',
            phone: '1234567890',
            location: 'Main Branch',
            department: 'Management',
            created_at: new Date(),
            updated_at: new Date()
        }], {});
    },

    async down(queryInterface, Sequelize) {
        return queryInterface.bulkDelete('Users', { email: 'supervisor@example.com' }, {});
    }
};
