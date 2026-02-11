'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('ActivitySettings', {
            activity_type: {
                type: Sequelize.STRING(50),
                primaryKey: true,
                allowNull: false
            },
            // Operational Matrix
            advancement_pts: {
                type: Sequelize.INTEGER,
                defaultValue: 85
            },
            max_capacity: {
                type: Sequelize.INTEGER,
                defaultValue: 10
            },
            time_limit_min: {
                type: Sequelize.INTEGER,
                defaultValue: 45
            },
            cool_down_sec: {
                type: Sequelize.INTEGER,
                defaultValue: 120
            },
            // Performance Weighing (%)
            weight_technical: {
                type: Sequelize.INTEGER,
                defaultValue: 40
            },
            weight_communication: {
                type: Sequelize.INTEGER,
                defaultValue: 35
            },
            weight_synergy: {
                type: Sequelize.INTEGER,
                defaultValue: 25
            },
            // System Switches
            auto_rewards: {
                type: Sequelize.BOOLEAN,
                defaultValue: true
            },
            intel_feedback: {
                type: Sequelize.BOOLEAN,
                defaultValue: true
            },
            created_at: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            },
            updated_at: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            }
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('ActivitySettings');
    }
};
