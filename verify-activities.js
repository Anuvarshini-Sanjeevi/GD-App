const http = require('http');

const PORT = 8080;

async function request(path, method, data, token) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: PORT,
            path: path,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                ...(token ? { 'Authorization': `Bearer ${token}` } : {})
            }
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

async function verifyTeamActivities() {
    try {
        console.log('--- Verifying Team Activities API ---');

        // 1. Login to get token for Demo Student (ID 1)
        console.log('\n1. Logging in as Demo Student...');
        const loginRes = await request('/auth/login', 'POST', {
            email: "admin@example.com", // Demo user in seeder uses this email
            password: "password123"
        });
        const token = loginRes.body.token;

        if (!token) {
            console.error('Login Failed. Make sure seeders are run.');
            return;
        }

        // 2. Fetch Team Activities
        console.log('\n2. Fetching Team Activities (GET /api/student/activities)...');
        const activitiesRes = await request('/api/student/activities', 'GET', null, token);

        console.log('Response Status:', activitiesRes.status);
        console.log('Activities Data:', JSON.stringify(activitiesRes.body, null, 2));

        if (!Array.isArray(activitiesRes.body)) {
            console.error('FAILURE: Response is not an array!');
            return;
        }

        const gd = activitiesRes.body.find(a => a.activity_type === 'GROUP_DISCUSSION');

        if (gd && gd.progress_percent === 30) {
            console.log('\nSUCCESS: Team Activities API correctly returned progress (30.00% for GD)!');
        } else {
            console.error('\nFAILURE: Progress percent mismatch or activity not found.');
        }

    } catch (error) {
        console.error('Verification Error:', error);
    }
}

verifyTeamActivities();
