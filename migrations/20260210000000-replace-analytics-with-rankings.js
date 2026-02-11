'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        // Drop the old AdminAnalytics table
        await queryInterface.dropTable('AdminAnalytics');

        // Create the new StudentRankings table
        await queryInterface.createTable('StudentRankings', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            student_id: {
                type: Sequelize.BIGINT,
                // We make it nullable so we can insert dummy data without users if needed, 
                // but ideally it links to Users. 
                allowNull: true,
                references: {
                    model: 'Users',
                    key: 'user_id'
                },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            name: {
                type: Sequelize.STRING,
                allowNull: false
            },
            photo: {
                type: Sequelize.STRING(512),
                allowNull: true
            },
            activity_type: {
                type: Sequelize.STRING(50),
                allowNull: false,
                defaultValue: 'GROUP_DISCUSSION'
                // Enum: 'GROUP_DISCUSSION', 'TECHNICAL_EVENTS', 'PRESENTATION', 'CASE_STUDY', 'DEBATE_CLUB'
            },
            level: {
                type: Sequelize.STRING(50),
                allowNull: false,
                defaultValue: 'OVERALL'
                // Enum: 'BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'OVERALL'
            },
            rank: {
                type: Sequelize.INTEGER,
                allowNull: false
            },
            points: {
                type: Sequelize.INTEGER,
                allowNull: false,
                defaultValue: 0
            },
            trend: {
                type: Sequelize.STRING(20),
                defaultValue: 'SAME'
                // Enum: 'UP', 'DOWN', 'SAME'
            },
            created_at: {
                allowNull: false,
                type: Sequelize.DATE
            },
            updated_at: {
                allowNull: false,
                type: Sequelize.DATE
            }
        });

        // Add indexes for faster querying
        await queryInterface.addIndex('StudentRankings', ['activity_type', 'level']);
    },

    down: async (queryInterface, Sequelize) => {
        // Drop StudentRankings
        await queryInterface.dropTable('StudentRankings');

        // Recreate AdminAnalytics (in case of rollback)
        await queryInterface.createTable('AdminAnalytics', {
            analytic_id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            admin_id: {
                type: Sequelize.INTEGER,
                allowNull: false,
                references: {
                    model: 'Admins',
                    key: 'admin_id'
                }
            },
            session_id: {
                type: Sequelize.INTEGER
            },
            analytic_type: {
                type: Sequelize.STRING(100),
                allowNull: false
            },
            data_json: {
                type: Sequelize.JSON,
                allowNull: false
            },
            generated_at: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            },
            created_at: {
                allowNull: false,
                type: Sequelize.DATE
            },
            updated_at: {
                allowNull: false,
                type: Sequelize.DATE
            }
        });
    }
};
