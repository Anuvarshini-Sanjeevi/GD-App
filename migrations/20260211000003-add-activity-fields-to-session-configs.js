'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('SessionConfigs', 'activity_type', {
            type: Sequelize.STRING(50),
            allowNull: true,
            references: {
                model: 'ActivitySettings',
                key: 'activity_type'
            },
            onUpdate: 'CASCADE',
            onDelete: 'SET NULL'
        });

        await queryInterface.addColumn('SessionConfigs', 'advancement_pts', {
            type: Sequelize.INTEGER,
            allowNull: true
        });

        await queryInterface.addColumn('SessionConfigs', 'cool_down_sec', {
            type: Sequelize.INTEGER,
            allowNull: true
        });

        await queryInterface.addColumn('SessionConfigs', 'weight_technical', {
            type: Sequelize.INTEGER,
            allowNull: true
        });

        await queryInterface.addColumn('SessionConfigs', 'weight_communication', {
            type: Sequelize.INTEGER,
            allowNull: true
        });

        await queryInterface.addColumn('SessionConfigs', 'weight_synergy', {
            type: Sequelize.INTEGER,
            allowNull: true
        });

        await queryInterface.addColumn('SessionConfigs', 'auto_rewards', {
            type: Sequelize.BOOLEAN,
            defaultValue: true
        });

        await queryInterface.addColumn('SessionConfigs', 'intel_feedback', {
            type: Sequelize.BOOLEAN,
            defaultValue: true
        });
    },

    async down(queryInterface, Sequelize) {
        const columns = [
            'activity_type',
            'advancement_pts',
            'cool_down_sec',
            'weight_technical',
            'weight_communication',
            'weight_synergy',
            'auto_rewards',
            'intel_feedback'
        ];
        for (const column of columns) {
            await queryInterface.removeColumn('SessionConfigs', column);
        }
    }
};
