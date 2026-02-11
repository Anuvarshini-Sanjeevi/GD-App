const http = require('http');

function getRankings(activity, level) {
    return new Promise((resolve, reject) => {
        const url = `http://localhost:8080/api/admin-analytics/rankings?activity=${activity}&level=${level}`;

        http.get(url, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    try {
                        resolve(JSON.parse(data));
                    } catch (e) {
                        reject(new Error('Failed to parse JSON'));
                    }
                } else {
                    reject(new Error(`Status Code: ${res.statusCode}`));
                }
            });
        }).on('error', (err) => {
            reject(err);
        });
    });
}

async function test() {
    try {
        console.log('--- Testing Overall Rankings ---');
        const overall = await getRankings('GROUP_DISCUSSION', 'OVERALL');
        console.log(`Fetched ${overall.length} records.`);
        if (overall.length > 0) {
            console.log('Top Rank:', overall[0].name, 'Points:', overall[0].points);
        } else {
            console.log('No overall records found.');
        }

        console.log('\n--- Testing Beginner Rankings ---');
        const beginner = await getRankings('GROUP_DISCUSSION', 'BEGINNER');
        console.log(`Fetched ${beginner.length} records.`);
        if (beginner.length > 0) {
            console.log('Top Rank:', beginner[0].name, 'Points:', beginner[0].points);
        } else {
            console.log('No beginner records found.');
        }

    } catch (error) {
        console.error('Test Failed:', error.message);
    }
}

test();
