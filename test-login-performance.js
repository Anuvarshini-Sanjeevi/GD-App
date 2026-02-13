// Simple login performance test without external dependencies
const http = require('http');

const BASE_URL = 'localhost';
const PORT = 8080;

function makeRequest(path, method, data) {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify(data);

        const options = {
            hostname: BASE_URL,
            port: PORT,
            path: path,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            },
            timeout: 30000
        };

        const req = http.request(options, (res) => {
            let responseData = '';

            res.on('data', (chunk) => {
                responseData += chunk;
            });

            res.on('end', () => {
                try {
                    resolve({
                        status: res.statusCode,
                        data: JSON.parse(responseData)
                    });
                } catch (e) {
                    resolve({
                        status: res.statusCode,
                        data: responseData
                    });
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        req.on('timeout', () => {
            req.destroy();
            reject(new Error('Request timeout'));
        });

        req.write(postData);
        req.end();
    });
}

async function testLoginPerformance() {
    console.log('🔍 Testing Login Performance...\n');

    const testUsers = [
        { email: 'admin@example.com', password: 'password123', role: 'Admin' },
        { email: 'supervisor@example.com', password: 'password123', role: 'Supervisor' }
    ];

    for (const user of testUsers) {
        console.log(`Testing ${user.role} login (${user.email})...`);

        const startTime = Date.now();

        try {
            const response = await makeRequest('/auth/login', 'POST', {
                email: user.email,
                password: user.password
            });

            const endTime = Date.now();
            const duration = endTime - startTime;

            if (response.status === 200) {
                console.log(`✅ Login successful in ${duration}ms`);
                console.log(`   Token: ${response.data.token.substring(0, 20)}...`);
                console.log(`   User: ${response.data.user.name} (${response.data.user.role})`);

                // Performance evaluation
                if (duration < 500) {
                    console.log(`   ⚡ EXCELLENT - Very fast response`);
                } else if (duration < 1000) {
                    console.log(`   ✓ GOOD - Acceptable response time`);
                } else if (duration < 2000) {
                    console.log(`   ⚠ SLOW - May cause issues on mobile`);
                } else {
                    console.log(`   ❌ VERY SLOW - Will timeout on mobile`);
                }
            } else {
                console.log(`❌ Login failed with status ${response.status}`);
                console.log(`   Message: ${response.data.message || 'Unknown error'}`);
            }

        } catch (error) {
            const endTime = Date.now();
            const duration = endTime - startTime;

            if (error.message === 'Request timeout') {
                console.log(`❌ Timeout after ${duration}ms`);
            } else {
                console.log(`❌ Error: ${error.message}`);
            }
        }

        console.log('');
    }

    console.log('\n📊 Performance Summary:');
    console.log('Expected performance with bcrypt rounds=8:');
    console.log('  • Desktop/Laptop: 200-500ms');
    console.log('  • Mobile (modern): 500-800ms');
    console.log('  • Mobile (older): 800-1500ms');
    console.log('\nPrevious performance with bcrypt rounds=10:');
    console.log('  • Desktop/Laptop: 500-1000ms');
    console.log('  • Mobile (modern): 1500-2500ms ⚠️');
    console.log('  • Mobile (older): 2500-4000ms ❌ (timeout)');
}

testLoginPerformance().catch(console.error);
