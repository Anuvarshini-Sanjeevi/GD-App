'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('ActivitySettings', 'category', {
            type: Sequelize.STRING(100),
            allowNull: true,
            defaultValue: 'General'
        });

        await queryInterface.addColumn('ActivitySettings', 'total_levels', {
            type: Sequelize.INTEGER,
            allowNull: false,
            defaultValue: 10
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('ActivitySettings', 'category');
        await queryInterface.removeColumn('ActivitySettings', 'total_levels');
    }
};
