const db = require('./models');
const controller = require('./controllers/adminAnalytics.controller');

// Mock Request and Response
const req = {
    query: {
        activity: 'GROUP_DISCUSSION',
        level: 'OVERALL'
    }
};

const res = {
    send: (data) => {
        console.log('SUCCESS: Retrieved ' + data.length + ' records.');
        console.log(JSON.stringify(data[0], null, 2));
    },
    status: (code) => {
        console.log('STATUS:', code);
        return {
            send: (data) => console.log('ERROR RESPONSE:', data)
        };
    }
};

async function testController() {
    try {
        await db.sequelize.authenticate();
        console.log('DB Connected.');

        console.log('Testing getRankings...');
        await controller.getRankings(req, res);

    } catch (error) {
        console.error('Test Script Error:', error);
    } finally {
        await db.sequelize.close();
    }
}

testController();
