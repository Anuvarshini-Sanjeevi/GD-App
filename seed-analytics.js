const db = require('./models');

async function seed() {
    try {
        await db.sequelize.authenticate();
        console.log('Database connected.');

        // Clear existing rankings
        await db.StudentRanking.destroy({ where: {}, truncate: true });
        console.log('Cleared existing Student Rankings.');

        const levels = ['OVERALL', 'BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'];
        const activities = ['GROUP_DISCUSSION'];
        // Can add 'TECHNICAL_EVENTS', 'PRESENTATION', etc. if needed later

        // Sample Data Generation
        const sampleTeams = [
            { name: "Team Alpha", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alpha" },
            { name: "Stellar Minds", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Stellar" },
            { name: "Quantum Peak", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Quantum" },
            { name: "Neural Net", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Neural" },
            { name: "Cyber Knights", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Cyber" },
            { name: "Data Drifters", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Drifter" },
            { name: "Logic Legion", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Logic" },
            { name: "Pixel Pioneers", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Pixel" },
            { name: "Code Crusaders", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Code" },
            { name: "Binary Bandits", photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Binary" }
        ];

        let rankings = [];

        for (const activity of activities) {
            for (const level of levels) {
                // Shuffle teams slightly for different rankings per level
                const levelTeams = [...sampleTeams].sort(() => 0.5 - Math.random());

                levelTeams.forEach((team, index) => {
                    rankings.push({
                        name: team.name,
                        photo: team.photo,
                        activity_type: activity,
                        level: level,
                        rank: index + 1,
                        points: 100 - (index * 5) + Math.floor(Math.random() * 5), // Randomize points slightly
                        trend: Math.random() > 0.5 ? 'UP' : (Math.random() > 0.5 ? 'DOWN' : 'SAME')
                    });
                });
            }
        }

        await db.StudentRanking.bulkCreate(rankings);
        console.log(`Seeded ${rankings.length} student rankings successfully.`);

    } catch (error) {
        console.error('Seeding failed:', error);
    } finally {
        await db.sequelize.close();
    }
}

seed();
