const db = require('./models');

async function listTables() {
    try {
        const tables = await db.sequelize.getQueryInterface().showAllSchemas();
        // For SQLite, showAllSchemas might behave differently or just returns tables. 
        // Better to use showAllTables usually, but let's try raw query if needed.
        // Sequelize showAllSchemas often returns objects.

        console.log('Tables in DB:');
        const allTables = await db.sequelize.showAllSchemas();
        console.log(allTables);

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await db.sequelize.close(); // Close connection
    }
}

listTables();
