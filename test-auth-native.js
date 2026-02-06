const http = require('http');

function request(path, method, data) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 3000,
            path: '/auth' + path,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data ? Buffer.byteLength(data) : 0
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    resolve({ status: res.statusCode, data: JSON.parse(body) });
                } catch (e) {
                    resolve({ status: res.statusCode, data: body });
                }
            });
        });

        req.on('error', (e) => reject(e));
        if (data) req.write(data);
        req.end();
    });
}

async function testAuth() {
    const testUser = {
        name: 'Test Student',
        email: 'test' + Date.now() + '@example.com',
        password: 'password123',
        role: 'student'
    };

    try {
        console.log('1. Testing Register...');
        const regRes = await request('/register', 'POST', JSON.stringify(testUser));
        console.log('Register:', regRes.status, regRes.data);

        if (regRes.status !== 201) throw new Error('Registration failed');

        console.log('\n2. Testing Login...');
        const loginRes = await request('/login', 'POST', JSON.stringify({
            email: testUser.email,
            password: testUser.password
        }));

        console.log('Login:', loginRes.status);
        if (loginRes.status === 200 && loginRes.data.token) {
            console.log('SUCCESS: Token received.');
        } else {
            console.error('Login Failed:', loginRes.data);
        }

    } catch (error) {
        console.error('Test Error:', error);
    }
}

testAuth();
