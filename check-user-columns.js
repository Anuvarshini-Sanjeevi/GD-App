const db = require('./models');

async function checkUserColumns() {
    try {
        const tableInfo = await db.sequelize.getQueryInterface().describeTable('Users');
        console.log('Columns:', Object.keys(tableInfo));
    } catch (error) {
        console.error('Error:', error);
    } finally {
        await db.sequelize.close();
    }
}

checkUserColumns();
