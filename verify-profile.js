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

async function verifyStudentProfile() {
    try {
        console.log('--- Verifying Student Profile API ---');

        // 1. Create a Test Student
        const email = `student_${Date.now()}@example.com`;
        console.log(`\n1. Registering test student: ${email}`);
        const regRes = await request('/auth/register', 'POST', {
            name: "Priya Sharma",
            email: email,
            password: "password123",
            role: "student"
        });

        console.log('Registration Status:', regRes.status);
        if (regRes.status !== 201) {
            console.error('Registration Failed:', regRes.body);
            return;
        }

        const student_id = regRes.body.user.id;

        // 2. Login to get token
        console.log('\n2. Logging in...');
        const loginRes = await request('/auth/login', 'POST', {
            email: email,
            password: "password123"
        });
        const token = loginRes.body.token;

        // 3. (Optional/Manual simulated insert) - We skip direct DB insert but simulated role check
        // Note: In real test, we'd use a seeder or direct DB tool to set roll_number/batch
        // For this check, we verify the fields exist (even if null) and context logic

        // 4. Fetch Profile
        console.log('\n3. Fetching Profile (GET /auth/me)...');
        const profileRes = await request('/auth/me', 'GET', null, token);

        console.log('Profile Data:');
        console.log(JSON.stringify(profileRes.body, null, 2));

        const fields = ['roll_number', 'batch', 'experience_points', 'rank'];
        const missing = fields.filter(f => !profileRes.body.hasOwnProperty(f));

        if (missing.length === 0) {
            console.log('\nSUCCESS: All student-specific fields are present in the profile response!');
        } else {
            console.error('\nFAILURE: Missing fields:', missing.join(', '));
        }

    } catch (error) {
        console.error('Verification Error:', error);
    }
}

verifyStudentProfile();
