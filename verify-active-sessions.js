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

async function verifySessions() {
    try {
        console.log('--- Verifying Active Sessions Logic ---');

        // 1. Create a WAITING session
        console.log('\nCreating WAITING session...');
        await request('/api/session-configs', 'POST', {
            session_id: 1001,
            status: 'WAITING',
            created_by_admin_id: 1
        });

        // 2. Create an ACTIVE session
        console.log('Creating ACTIVE session...');
        await request('/api/session-configs', 'POST', {
            session_id: 1002,
            status: 'ACTIVE',
            created_by_admin_id: 1
        });

        // 3. Create a COMPLETED session
        console.log('Creating COMPLETED session...');
        await request('/api/session-configs', 'POST', {
            session_id: 1003,
            status: 'COMPLETED',
            created_by_admin_id: 1
        });

        // 4. Fetch Active Sessions
        console.log('\nFetching Active Sessions (GET /api/session-configs/active)...');
        const activeRes = await request('/api/session-configs/active', 'GET');

        console.log('Results:');
        console.log(JSON.stringify(activeRes.body, null, 2));

        const activeIds = activeRes.body.map(s => s.session_id);
        const hasActive = activeIds.includes(1002);
        const hasWaiting = activeIds.includes(1001);
        const hasCompleted = activeIds.includes(1003);

        if (hasActive && !hasWaiting && !hasCompleted) {
            console.log('\nSUCCESS: Only ACTIVE sessions are returned!');
        } else {
            console.error('\nFAILURE: Filtering logic incorrect.');
            console.log('Active:', hasActive, 'Waiting:', hasWaiting, 'Completed:', hasCompleted);
        }

    } catch (error) {
        console.error('Verification Error:', error);
    }
}

verifySessions();
