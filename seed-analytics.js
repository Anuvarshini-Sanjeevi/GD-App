const db = require('./models');

async function seed() {
    try {
        await db.sequelize.authenticate();
        console.log('Database connected.');

        // Ensure Admin 1 exists
        let admin = await db.Admin.findByPk(1);
        if (!admin) {
            admin = await db.Admin.create({
                admin_id: 1,
                name: 'Initial Admin',
                email: 'admin@example.com',
                password_hash: 'admin123'
            });
            console.log('Default admin created.');
        }

        // Delete old analytics to avoid duplication during testing
        await db.AdminAnalytics.destroy({ where: { analytic_type: 'GROUP_DISCUSSION' } });

        // Create Sample Group Discussion Analytics with Names and Photos
        await db.AdminAnalytics.create({
            admin_id: 1,
            session_id: 101,
            analytic_type: 'GROUP_DISCUSSION',
            data_json: {
                champion: {
                    name: "Team Alpha",
                    photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alpha",
                    engagement: "89%",
                    pts: 98
                },
                leaderboard: [
                    {
                        rank: 1,
                        name: "Team Alpha",
                        photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alpha",
                        engagement: "89%",
                        pts: 98,
                        subtext: "89% ENGAGEMENT"
                    },
                    {
                        rank: 2,
                        name: "Stellar Minds",
                        photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Stellar",
                        engagement: "82%",
                        pts: 94,
                        subtext: "82% CONSISTENCY"
                    },
                    {
                        rank: 3,
                        name: "Quantum Peak",
                        photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Quantum",
                        engagement: "78%",
                        pts: 91,
                        subtext: "78% FLUIDITY"
                    }
                ]
            }
        });

        console.log('Rich Group Discussion analytics created with photos and names!');
    } catch (error) {
        console.error('Seeding failed:', error);
    } finally {
        await db.sequelize.close();
    }
}

seed();
