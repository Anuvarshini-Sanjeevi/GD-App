'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.addColumn('HallQrTokens', 'join_window_minutes', {
            type: Sequelize.INTEGER,
            allowNull: true,
            defaultValue: 5 // Default to 5 minutes if not specified
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.removeColumn('HallQrTokens', 'join_window_minutes');
    }
};
