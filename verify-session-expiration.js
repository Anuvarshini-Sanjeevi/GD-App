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

async function verify() {
    try {
        console.log('--- Verifying Activity-Type and Session Expiration ---');

        // 1. Ensure ActivitySetting exists or just use a dummy activity_type
        // Note: activity_type TECHNICAL should exist based on standard GD setup

        const timestamp = Date.now();
        const sessionId = 3000 + (timestamp % 1000);

        // 2. Create Session with short limit
        console.log(`Creating session ${sessionId} with 1 min limit...`);
        const createRes = await request('/api/session-configs', 'POST', {
            session_id: sessionId,
            activity_type: 'TECHNICAL_EVENTS',
            activity_duration_minutes: 1,
            status: 'WAITING',
            created_by_admin_id: 1
        });

        if (createRes.status >= 400) {
            console.error('Session creation failed:', createRes.body);
            return;
        }

        const configId = createRes.body.config_id;
        console.log('Created Config ID:', configId);

        // 3. Create HallQrToken
        console.log('Creating HallQrToken with activity_type and start_time...');
        const tokenRes = await request('/api/hall-qr-tokens', 'POST', {
            hall_qr_token: `TEST-TOKEN-${timestamp}`,
            session_id: sessionId,
            activity_type: 'TECHNICAL_EVENTS',
            start_time: '10:08 PM',
            created_by_admin_id: 1
        });
        console.log('Token created status:', tokenRes.status);
        console.log('Token activity_type:', tokenRes.body.activity_type);
        console.log('Token start_time:', tokenRes.body.start_time);

        if (tokenRes.body.start_time !== '10:08 PM') {
            console.error('FAILURE: start_time not stored correctly. Found:', tokenRes.body.start_time);
        } else {
            console.log('SUCCESS: start_time stored correctly!');
        }

        // 4. Start Session
        console.log('Starting session (setting to ACTIVE)...');
        const updateRes = await request(`/api/session-configs/${configId}`, 'PUT', { status: 'ACTIVE' });
        console.log('Update status:', updateRes.status);

        // 5. Verify ACTIVE
        let session = await request(`/api/session-configs/${configId}`, 'GET');
        console.log('Current Reported Status:', session.body.status);
        if (session.body.status !== 'ACTIVE') {
            console.error('Session should be ACTIVE but is:', session.body.status);
            return;
        }

        // 6. Wait 65 seconds
        console.log('Waiting 65 seconds for expiration...');
        await new Promise(r => setTimeout(r, 65000));

        // 7. Verify INACTIVE
        session = await request(`/api/session-configs/${configId}`, 'GET');
        console.log('Status after 65s:', session.body.status);
        console.log('Final Session Details:', JSON.stringify(session.body, null, 2));

        if (session.body.status === 'INACTIVE') {
            console.log('\nSUCCESS: Session automatically reported as INACTIVE!');
        } else {
            console.error('\nFAILURE: Session still reporting as', session.body.status);
        }

    } catch (error) {
        console.error('Verification Error:', error.stack || error);
    }
}

verify();
