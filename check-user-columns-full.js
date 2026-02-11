const db = require('./models');

async function checkUserColumns() {
    try {
        const tableInfo = await db.sequelize.getQueryInterface().describeTable('Users');
        console.log('Columns:', JSON.stringify(Object.keys(tableInfo), null, 2));
    } catch (error) {
        console.error('Error:', error);
    } finally {
        await db.sequelize.close();
    }
}

checkUserColumns();
