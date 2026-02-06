const { Sequelize } = require('sequelize');
const config = require('./config/config.js').development;

console.log('Testing connection with config:', {
    host: config.host,
    username: config.username,
    database: config.database,
    dialect: config.dialect
});

const sequelize = new Sequelize(config.database, config.username, config.password, config);

(async () => {
    try {
        await sequelize.authenticate();
        console.log('Connection has been established successfully.');
        process.exit(0);
    } catch (error) {
        console.error('Unable to connect to the database:', error);
        process.exit(1);
    }
})();
