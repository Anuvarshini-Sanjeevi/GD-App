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

async function verifyLogin() {
    try {
        console.log('--- Verifying Unified Login API ---');

        const testUsers = [
            { label: 'Admin', username: 'admin@example.com' },
            { label: 'Supervisor', username: 'supervisor@example.com' },
            { label: 'Student', username: 'student_1770792586178@example.com' }
        ];

        for (const user of testUsers) {
            console.log(`\nTesting Login for ${user.label}...`);
            const res = await request('/auth/login', 'POST', {
                username: user.username,
                password: 'password123'
            });

            if (res.status === 200) {
                console.log(`SUCCESS: Logged in as ${res.body.user.role} (${res.body.user.email})`);
            } else {
                console.error(`FAILURE: Status ${res.status}`, JSON.stringify(res.body));
            }
        }

        console.log('\nTesting Blocked Registration...');
        const regRes = await request('/auth/register', 'POST', {
            name: "New", email: "new@ex.com", password: "p", role: "student"
        });
        if (regRes.status === 404) {
            console.log('SUCCESS: Registration is indeed blocked (404 Not Found).');
        } else {
            console.warn(`NOTE: Registration returned ${regRes.status}. Expected 404 since it was removed/commented.`);
        }

    } catch (error) {
        console.error('Verification Error:', error);
    }
}

verifyLogin();
