const db = require('./models');

async function checkUserTable() {
    try {
        const tableInfo = await db.sequelize.getQueryInterface().describeTable('Users');
        console.log('Users Table Info:', JSON.stringify(tableInfo, null, 2));
    } catch (error) {
        console.error('Error:', error);
    } finally {
        await db.sequelize.close();
    }
}

checkUserTable();
