'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('HallQrTokens', 'activity_type', {
            type: Sequelize.STRING(50),
            allowNull: true,
            references: {
                model: 'ActivitySettings',
                key: 'activity_type'
            },
            onUpdate: 'CASCADE',
            onDelete: 'SET NULL'
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('HallQrTokens', 'activity_type');
    }
};
