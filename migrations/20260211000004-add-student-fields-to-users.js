'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('Users', 'roll_number', {
            type: Sequelize.STRING(50),
            allowNull: true,
            unique: true
        });

        await queryInterface.addColumn('Users', 'batch', {
            type: Sequelize.STRING(50),
            allowNull: true
        });

        await queryInterface.addColumn('Users', 'experience_points', {
            type: Sequelize.INTEGER,
            defaultValue: 0,
            allowNull: false
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('Users', 'roll_number');
        await queryInterface.removeColumn('Users', 'batch');
        await queryInterface.removeColumn('Users', 'experience_points');
    }
};
