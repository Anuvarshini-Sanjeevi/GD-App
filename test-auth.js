const fetch = require('node-fetch'); // Fallback if global fetch missing, but we'll try global first.

async function testAuth() {
    const baseUrl = 'http://localhost:3000/auth';
    const testUser = {
        name: 'Test Student',
        email: 'test' + Date.now() + '@example.com',
        password: 'password123',
        role: 'student'
    };

    try {
        // 1. Register
        console.log('1. Testing Register...');
        const regRes = await fetch(`${baseUrl}/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(testUser)
        });

        const regData = await regRes.json();
        console.log('Register Response:', regRes.status, regData);

        if (regRes.status !== 201) throw new Error('Registration failed');

        // 2. Login
        console.log('\n2. Testing Login...');
        const loginRes = await fetch(`${baseUrl}/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: testUser.email, password: testUser.password })
        });

        const loginData = await loginRes.json();
        console.log('Login Response:', loginRes.status);

        if (loginRes.status === 200 && loginData.token) {
            console.log('SUCCESS: Token received:', loginData.token.substring(0, 20) + '...');
        } else {
            console.error('Login Failed:', loginData);
        }

    } catch (error) {
        if (error.code === 'MODULE_NOT_FOUND') {
            console.log("Fetch module missing, trying built-in fetch...");
            // Re-run with built-in fetch if needed, but this script assumes node version has it or it throws.
            // Actually, let's just use a simple http request wrapper if this fails, but for now let's hope node is recent.
        }
        console.error('Test Error:', error);
    }
}

// Check for global fetch, if not try to require it (which likely fails if not installed), 
// so we wrap to ensure execution
if (!globalThis.fetch) {
    console.log("Global fetch not found. Install node-fetch or use Node 18+");
} else {
    testAuth();
}
