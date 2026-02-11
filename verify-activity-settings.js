const http = require('http');

const PORT = 8080;

async function request(path, method, data) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: PORT,
            path: path,
            method: method,
            headers: { 'Content-Type': 'application/json' }
        };

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    resolve({ status: res.statusCode, body: body ? JSON.parse(body) : {} });
                } catch (e) {
                    resolve({ status: res.statusCode, body: body });
                }
            });
        });

        req.on('error', reject);
        if (data) req.write(JSON.stringify(data));
        req.end();
    });
}

async function verifyActivitySettings() {
    try {
        console.log('--- Verifying Activity Settings API ---');

        // 1. Get Group Discussion settings
        console.log('\nFetching Group Discussion settings...');
        const gdRes = await request('/api/activity-settings/GROUP_DISCUSSION', 'GET');
        console.log('Status:', gdRes.status);
        console.log('Data:', JSON.stringify(gdRes.body, null, 2));

        if (gdRes.status === 200 && gdRes.body.advancement_pts === 85) {
            console.log('SUCCESS: Default settings retrieved correctly.');
        } else {
            console.error('FAILURE: Default settings mismatch.');
        }

        // 2. Update settings
        console.log('\nUpdating Group Discussion time limit to 50 mins...');
        const updateRes = await request('/api/activity-settings/GROUP_DISCUSSION', 'PUT', {
            time_limit_min: 50
        });
        console.log('Update Status:', updateRes.status);

        // 3. Verify update
        console.log('\nRe-fetching Group Discussion settings to verify update...');
        const verifyRes = await request('/api/activity-settings/GROUP_DISCUSSION', 'GET');
        if (verifyRes.body.time_limit_min === 50) {
            console.log('SUCCESS: Time limit updated successfully!');
        } else {
            console.error('FAILURE: Update did not persist.');
        }

    } catch (error) {
        console.error('Verification Error:', error);
    }
}

verifyActivitySettings();
