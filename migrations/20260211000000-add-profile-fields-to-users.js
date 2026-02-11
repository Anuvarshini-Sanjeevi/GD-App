'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('Users', 'phone', {
            type: Sequelize.STRING(20),
            allowNull: true
        });
        await queryInterface.addColumn('Users', 'location', {
            type: Sequelize.STRING(255),
            allowNull: true
        });
        await queryInterface.addColumn('Users', 'department', {
            type: Sequelize.STRING(255),
            allowNull: true
        });
        await queryInterface.addColumn('Users', 'last_login', {
            type: Sequelize.DATE,
            allowNull: true
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('Users', 'phone');
        await queryInterface.removeColumn('Users', 'location');
        await queryInterface.removeColumn('Users', 'department');
        await queryInterface.removeColumn('Users', 'last_login');
    }
};
