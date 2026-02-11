'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        // Clear existing data
        await queryInterface.bulkDelete('StudentRankings', null, {});

        const rankings = [];
        const activities = ['GROUP_DISCUSSION', 'TECHNICAL_EVENTS', 'PRESENTATION', 'CASE_STUDY', 'DEBATE_CLUB'];
        const levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'OVERALL'];

        // Sample student names (using generic names or fetched from Users if possible, but hardcoding for now as per plan)
        const students = [
            { name: 'Unknown Team', photo: null },
            { name: 'Alpha Team', photo: null },
            { name: 'Beta Squad', photo: null },
            { name: 'Gamma Group', photo: null },
            { name: 'Delta Force', photo: null }
        ];

        let idCounter = 1;

        for (const activity of activities) {
            for (const level of levels) {
                // Shuffle students for variety
                const shuffledStudents = [...students].sort(() => 0.5 - Math.random());

                shuffledStudents.forEach((student, index) => {
                    rankings.push({
                        // id: idCounter++, // Let auto-increment handle it
                        student_id: null, //Or link to existing users if known
                        name: student.name,
                        photo: student.photo,
                        activity_type: activity,
                        level: level,
                        rank: index + 1,
                        points: 1000 - (index * 50) + Math.floor(Math.random() * 20),
                        trend: ['UP', 'DOWN', 'SAME'][Math.floor(Math.random() * 3)],
                        created_at: new Date(),
                        updated_at: new Date()
                    });
                });
            }
        }

        await queryInterface.bulkInsert('StudentRankings', rankings, {});
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.bulkDelete('StudentRankings', null, {});
    }
};
