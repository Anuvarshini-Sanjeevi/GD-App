const http = require('http');

const PORT = 8080;
const BASE_URL = `http://localhost:${PORT}`;

async function request(path, method, data, token) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: PORT,
            path: path,
            method: method,
            headers: {
                'Content-Type': 'application/json',
            }
        };

        if (token) {
            options.headers['Authorization'] = `Bearer ${token}`;
        }

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const parsed = body ? JSON.parse(body) : {};
                    resolve({ status: res.statusCode, body: parsed });
                } catch (e) {
                    resolve({ status: res.statusCode, body: body });
                }
            });
        });

        req.on('error', (e) => reject(e));
        if (data) {
            req.write(JSON.stringify(data));
        }
        req.end();
    });
}

async function testProfile() {
    try {
        console.log('--- Testing Auth & Profile API ---');

        // 1. Login with seeded user
        console.log('\n1. Logging in...');
        const loginRes = await request('/auth/login', 'POST', {
            email: 'admin@example.com',
            password: 'password123'
        });

        if (loginRes.status !== 200) {
            console.error('Login Failed:', loginRes.body);
            return;
        }

        const token = loginRes.body.token;
        console.log('Login Successful! Token received.');

        // 2. Fetch Profile
        console.log('\n2. Fetching profile using token...');
        const profileRes = await request('/auth/me', 'GET', null, token);

        if (profileRes.status !== 200) {
            console.error('Fetch Profile Failed:', profileRes.body);
            return;
        }

        console.log('Profile Fetched Successfully:');
        console.log(JSON.stringify(profileRes.body, null, 2));

        if (profileRes.body.email === 'admin@example.com') {
            console.log('\nSUCCESS: Profile matches logged-in user!');
        } else {
            console.error('\nFAILURE: Profile mismatch!');
        }

    } catch (error) {
        console.error('Test Error:', error);
    }
}

testProfile();
