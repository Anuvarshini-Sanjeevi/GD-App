'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        // We assume the demo student from 20260206081302-demo-user.js has user_id 1
        // Let's seed some progress for student_id 1
        return queryInterface.bulkInsert('StudentActivityProgress', [
            {
                student_id: 1,
                activity_type: 'GROUP_DISCUSSION',
                completed_levels: 3,
                created_at: new Date(),
                updated_at: new Date()
            },
            {
                student_id: 1,
                activity_type: 'TECHNICAL_EVENTS',
                completed_levels: 1,
                created_at: new Date(),
                updated_at: new Date()
            },
            {
                student_id: 1,
                activity_type: 'PRESENTATION',
                completed_levels: 0,
                created_at: new Date(),
                updated_at: new Date()
            }
        ], {});
    },

    async down(queryInterface, Sequelize) {
        return queryInterface.bulkDelete('StudentActivityProgress', null, {});
    }
};
