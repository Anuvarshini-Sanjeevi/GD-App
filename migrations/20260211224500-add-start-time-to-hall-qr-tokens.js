'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('HallQrTokens', 'start_time', {
            type: Sequelize.STRING(50), // Storing as string to match the user's "10:08 PM" format or similar
            allowNull: true
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('HallQrTokens', 'start_time');
    }
};
