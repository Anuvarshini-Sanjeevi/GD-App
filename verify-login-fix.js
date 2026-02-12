const http = require('http');

async function testLogin(body, contentType) {
    return new Promise((resolve) => {
        const data = body ? JSON.stringify(body) : null;
        const options = {
            hostname: 'localhost',
            port: 8080, // Updated from 3000 to 8080 based on .env
            path: '/auth/login',
            method: 'POST',
            headers: {
                'Content-Type': contentType || 'application/json'
            }
        };

        if (data) {
            options.headers['Content-Length'] = Buffer.byteLength(data);
        } else {
            delete options.headers['Content-Type'];
        }

        const req = http.request(options, (res) => {
            let resData = '';
            res.on('data', (chunk) => { resData += chunk; });
            res.on('end', () => {
                try {
                    resolve({
                        status: res.statusCode,
                        data: JSON.parse(resData)
                    });
                } catch (e) {
                    resolve({
                        status: res.statusCode,
                        data: resData
                    });
                }
            });
        });

        req.on('error', (e) => {
            resolve({ status: 500, error: e.message });
        });

        if (data) req.write(data);
        req.end();
    });
}

async function runTests() {
    console.log('--- Starting Verification Tests ---');

    console.log('\nTest 1: Login with NO BODY (Should return 400, not crash)');
    const res1 = await testLogin(null);
    console.log('Status:', res1.status);
    console.log('Data:', res1.data);

    console.log('\nTest 2: Login with WRONG CONTENT-TYPE (Should return 400, not crash)');
    const res2 = await testLogin({ email: 'test@example.com' }, 'text/plain');
    console.log('Status:', res2.status);
    console.log('Data:', res2.data);

    console.log('\nTest 3: Login with CORRECT BODY (Should return 401 - Invalid credentials, or 200)');
    const res3 = await testLogin({ email: 'wrong@test.com', password: 'wrong' });
    console.log('Status:', res3.status);
    console.log('Data:', res3.data);

    if (res1.status === 400 && res2.status === 400) {
        console.log('\n✅ VERIFICATION SUCCESSFUL: Server is no longer crashing on malformed requests.');
    } else {
        console.log('\n❌ VERIFICATION FAILED: Server behavior is unexpected.');
    }
}

runTests();
