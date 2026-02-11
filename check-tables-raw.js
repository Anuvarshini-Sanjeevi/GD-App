const db = require('./models');

async function listTables() {
    try {
        const [results, metadata] = await db.sequelize.query("SHOW TABLES");
        console.log('Tables:', JSON.stringify(results, null, 2));
    } catch (error) {
        console.error('Error:', error);
    } finally {
        await db.sequelize.close();
    }
}

listTables();
