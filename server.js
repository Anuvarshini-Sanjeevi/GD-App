const app = require('./app');
const db = require('./models');

const PORT = process.env.PORT || 3000;

async function startServer() {
    try {
        // Authenticate database connection
        await db.sequelize.authenticate();
        console.log('Database connection has been established successfully.');

        // Get LAN IP address
        const { networkInterfaces } = require('os');
        const nets = networkInterfaces();
        let lanIp = 'localhost';

        for (const name of Object.keys(nets)) {
            for (const net of nets[name]) {
                // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
                if (net.family === 'IPv4' && !net.internal) {
                    lanIp = net.address;
                }
            }
        }

        // Start server
        const server = app.listen(PORT, '0.0.0.0', () => {
            console.log(`\n🚀 Server is running on port ${PORT}.`);
            console.log(`\n📡 To connect from mobile/other devices:`);
            console.log(`   Use this URL: http://${lanIp}:${PORT}`);
            console.log(`   (Ensure your mobile is on the same WiFi network)\n`);
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
