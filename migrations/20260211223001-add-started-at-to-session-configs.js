'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        // Add started_at column
        await queryInterface.addColumn('SessionConfigs', 'started_at', {
            type: Sequelize.DATE,
            allowNull: true
        });

        // Note: SQLite doesn't support changing ENUMs easily. 
        // If it's MySQL/Postgres, we'd alter the column. 
        // For SQLite, we just ensure the model allows 'INACTIVE'.
        // However, looking at previous migrations, it seems to be using ENUMs.
        // Let's attempt to modify the column if the DB supports it, or just rely on the model for now.
        // Since sqlite is used (from list_dir results), ENUM is just a string with check constraints.
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.removeColumn('SessionConfigs', 'started_at');
    }
};
