'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        // Add index on Users.email for faster login queries
        await queryInterface.addIndex('Users', ['email'], {
            name: 'idx_users_email',
            unique: true
        });

        // Add index on Admins.email for faster admin login queries
        await queryInterface.addIndex('Admins', ['email'], {
            name: 'idx_admins_email',
            unique: true
        });
    },

    down: async (queryInterface, Sequelize) => {
        // Remove indexes
        await queryInterface.removeIndex('Users', 'idx_users_email');
        await queryInterface.removeIndex('Admins', 'idx_admins_email');
    }
};
