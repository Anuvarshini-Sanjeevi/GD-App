const app = require('./app');
const db = require('./models');

const PORT = process.env.PORT || 3000;

async function startServer() {
    try {
        // Authenticate database connection
        await db.sequelize.authenticate();
        console.log('Database connection has been established successfully.');

        // Start server
        const server = app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}.`);
        });

        server.on('error', (error) => {
            if (error.code === 'EADDRINUSE') {
                console.error(`Port ${PORT} is already in use. Please close the other process or use a different port.`);
            } else {
                console.error('Server error:', error);
            }
            process.exit(1);
        });

    } catch (error) {
        console.error('Unable to connect to the database:', error);
        process.exit(1);
    }
}

startServer();
