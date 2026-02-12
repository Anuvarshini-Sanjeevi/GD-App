'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        const settings = [
            { activity_type: 'GROUP_DISCUSSION', advancement_pts: 85, max_capacity: 10, time_limit_min: 45, cool_down_sec: 30, weight_technical: 40, weight_communication: 35, weight_synergy: 25, auto_rewards: true, intel_feedback: true, category: 'Collaboration', total_levels: 10, created_at: new Date(), updated_at: new Date() },
            { activity_type: 'TECHNICAL_EVENTS', advancement_pts: 95, max_capacity: 5, time_limit_min: 60, cool_down_sec: 60, weight_technical: 70, weight_communication: 15, weight_synergy: 15, auto_rewards: true, intel_feedback: false, category: 'Technical Skills', total_levels: 8, created_at: new Date(), updated_at: new Date() },
            { activity_type: 'PRESENTATION', advancement_pts: 80, max_capacity: 4, time_limit_min: 15, cool_down_sec: 120, weight_technical: 30, weight_communication: 50, weight_synergy: 20, auto_rewards: false, intel_feedback: true, category: 'Communication', total_levels: 5, created_at: new Date(), updated_at: new Date() },
            { activity_type: 'CASE_STUDY', advancement_pts: 90, max_capacity: 6, time_limit_min: 90, cool_down_sec: 60, weight_technical: 50, weight_communication: 20, weight_synergy: 30, auto_rewards: true, intel_feedback: true, category: 'Problem Solving', total_levels: 12, created_at: new Date(), updated_at: new Date() },
            { activity_type: 'DEBATE_CLUB', advancement_pts: 88, max_capacity: 8, time_limit_min: 30, cool_down_sec: 45, weight_technical: 20, weight_communication: 60, weight_synergy: 20, auto_rewards: true, intel_feedback: true, category: 'Communication', total_levels: 10, created_at: new Date(), updated_at: new Date() }
        ];

        return queryInterface.bulkInsert('ActivitySettings', settings);
    },

    async down(queryInterface, Sequelize) {
        return queryInterface.bulkDelete('ActivitySettings', null, {});
    }
};
