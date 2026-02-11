'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('SessionConfigs', 'status', {
            type: Sequelize.ENUM('WAITING', 'ACTIVE', 'COMPLETED', 'CANCELLED'),
            defaultValue: 'WAITING',
            allowNull: false
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('SessionConfigs', 'status');
        // Note: To truly undo, we might need to drop the Enum type in some DBs, 
        // but column removal is the primary step.
    }
};
