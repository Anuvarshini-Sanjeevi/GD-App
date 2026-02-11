const db = require('./models');

async function debugSeeder() {
    try {
        console.log('Attempting to check/create user...');

        // Find if user exists
        const existing = await db.User.findOne({ where: { email: 'admin@example.com' } });
        if (existing) {
            console.log('User exists, deleting...');
            // Need to handle foreign keys? StudentRankings might have student_id=existing.user_id
            await existing.destroy();
        }

        const userData = {
            name: 'Initial Admin',
            email: 'admin@example.com',
            password: 'password123',
            role: 'admin',
            phone: 'Not Provided',
            location: 'Headquarters',
            department: 'Computer Science & Engineering',
            createdAt: new Date(),
            updatedAt: new Date()
        };

        console.log('Creating user with data:', JSON.stringify(userData, null, 2));
        const user = await db.User.create(userData);
        console.log('User created successfully:', user.dataValues);

    } catch (error) {
        console.error('FAILED to create user:');
        if (error.name === 'SequelizeValidationError' || error.name === 'SequelizeUniqueConstraintError') {
            console.error('Validation Errors:', error.errors.map(e => ({
                message: e.message,
                field: e.path,
                value: e.value
            })));
        } else {
            console.error('Error Name:', error.name);
            console.error('Error Message:', error.message);
            if (error.original) {
                console.error('Original Error:', error.original.message);
            }
        }
    } finally {
        await db.sequelize.close();
    }
}

debugSeeder();
