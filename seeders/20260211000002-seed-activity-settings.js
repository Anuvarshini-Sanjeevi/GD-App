'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        const activities = [
            'GROUP_DISCUSSION',
            'TECHNICAL_EVENTS',
            'PRESENTATION',
            'CASE_STUDY',
            'DEBATE_CLUB'
        ];

        const settings = activities.map(type => ({
            activity_type: type,
            advancement_pts: 85,
            max_capacity: 10,
            time_limit_min: 45,
            cool_down_sec: 120,
            weight_technical: 40,
            weight_communication: 35,
            weight_synergy: 25,
            auto_rewards: true,
            intel_feedback: true,
            created_at: new Date(),
            updated_at: new Date()
        }));

        return queryInterface.bulkInsert('ActivitySettings', settings);
    },

    async down(queryInterface, Sequelize) {
        return queryInterface.bulkDelete('ActivitySettings', null, {});
    }
};
