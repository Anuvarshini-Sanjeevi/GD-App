'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('StudentActivityProgress', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            student_id: {
                type: Sequelize.BIGINT,
                allowNull: false,
                references: {
                    model: 'Users',
                    key: 'user_id'
                },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE'
            },
            activity_type: {
                type: Sequelize.STRING(50),
                allowNull: false,
                references: {
                    model: 'ActivitySettings',
                    key: 'activity_type'
                },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE'
            },
            completed_levels: {
                type: Sequelize.INTEGER,
                defaultValue: 0,
                allowNull: false
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

        // Add composite unique constraint
        await queryInterface.addConstraint('StudentActivityProgress', {
            fields: ['student_id', 'activity_type'],
            type: 'unique',
            name: 'unique_student_activity_progress'
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('StudentActivityProgress');
    }
};
