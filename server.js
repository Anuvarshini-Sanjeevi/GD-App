const app = require('./app');
const db = require('./models');

const PORT = process.env.PORT || 3000;

async function startServer() {
    try {
        // Authenticate database connection
        await db.sequelize.authenticate();
        console.log('Database connection has been established successfully.');

        // Start server
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}.`);
        });
    } catch (error) {
        console.error('Unable to connect to the database:', error);
        process.exit(1);
    }
}

startServer();
