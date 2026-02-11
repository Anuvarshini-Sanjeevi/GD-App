const db = require('./models');

async function verifyUser() {
    try {
        const user = await db.User.findOne({
            where: { email: 'admin@example.com' }
        });

        if (user) {
            console.log('Initial Admin Found:');
            console.log(JSON.stringify(user.toJSON(), null, 2));
        } else {
            console.log('Initial Admin NOT FOUND');
        }
    } catch (error) {
        console.error('Verification Error:', error);
    } finally {
        await db.sequelize.close();
    }
}

verifyUser();
