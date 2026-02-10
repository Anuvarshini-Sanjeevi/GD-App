const db = require('./models');

async function seed() {
    try {
        await db.sequelize.authenticate();
        console.log('Database connected.');

        // Create a dummy admin if none exists
        const adminCount = await db.Admin.count();
        if (adminCount === 0) {
            await db.Admin.create({
                admin_id: 1,
                name: 'Initial Admin',
                email: 'admin@example.com',
                password_hash: 'admin123'
            });
            console.log('Dummy admin created with ID 1.');
        } else {
            console.log('Admins already exist.');
        }
    } catch (error) {
        console.error('Seeding failed:', error);
    } finally {
        await db.sequelize.close();
    }
}

seed();
