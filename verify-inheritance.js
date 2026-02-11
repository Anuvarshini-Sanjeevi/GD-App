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

async function verifyInheritance() {
    try {
        console.log('--- Verifying Session Configuration Inheritance ---');

        // 1. Update Calibration Panel for GROUP_DISCUSSION
        console.log('\n1. Updating Calibration Panel (GROUP_DISCUSSION)...');
        await request('/api/activity-settings/GROUP_DISCUSSION', 'PUT', {
            advancement_pts: 99,
            time_limit_min: 15, // Should map to activity_duration_minutes
            weight_technical: 60
        });

        // 2. Create a Session with activity_type but WITHOUT calibration fields
        console.log('\n2. Creating Session (Inheriting from GROUP_DISCUSSION)...');
        const createRes = await request('/api/session-configs', 'POST', {
            session_id: 2001,
            activity_type: 'GROUP_DISCUSSION',
            created_by_admin_id: 1
        });

        console.log('Create Status:', createRes.status);
        const config = createRes.body;

        // 3. Verify values
        console.log('\n3. Verifying Inherited Values:');
        console.log('Advancement Pts:', config.advancement_pts, '(Expected: 99)');
        console.log('Activity Duration:', config.activity_duration_minutes, '(Expected: 15)');
        console.log('Technical Weight:', config.weight_technical, '(Expected: 60)');

        if (config.advancement_pts === 99 && config.activity_duration_minutes === 15 && config.weight_technical === 60) {
            console.log('\nSUCCESS: Session successfully inherited configurations from the Calibration Panel!');
        } else {
            console.error('\nFAILURE: Inheritance logic failed.');
        }

    } catch (error) {
        console.error('Verification Error:', error);
    }
}

verifyInheritance();
