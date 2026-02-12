'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('SessionConfigs', 'protocol', {
            type: Sequelize.STRING(100),
            allowNull: true
        });

        await queryInterface.addColumn('SessionConfigs', 'start_time', {
            type: Sequelize.STRING(50),
            allowNull: true
        });

        await queryInterface.addColumn('SessionConfigs', 'complexity_level', {
            type: Sequelize.STRING(50),
            allowNull: true
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('SessionConfigs', 'protocol');
        await queryInterface.removeColumn('SessionConfigs', 'start_time');
        await queryInterface.removeColumn('SessionConfigs', 'complexity_level');
    }
};
