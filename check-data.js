const db = require('./models');

async function checkData() {
    try {
        const count = await db.StudentRanking.count();
        console.log(`StudentRankings count: ${count}`);

        const sample = await db.StudentRanking.findOne();
        console.log('Sample:', JSON.stringify(sample, null, 2));
    } catch (error) {
        console.error('Error:', error);
    } finally {
        await db.sequelize.close();
    }
}

checkData();
