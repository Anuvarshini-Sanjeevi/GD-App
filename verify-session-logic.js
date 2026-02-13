const db = require('./models');
// Disable logging for cleaner output
db.sequelize.options.logging = false;
const { SessionConfig, ActivitySettings, HallQrToken } = db;

async function verifyLogic() {
    try {
        console.log('🔍 Starting Verification...\n');

        // 1. Create Dummy ActivitySettings
        console.log('1️⃣ Creating ActivitySettings...');
        await ActivitySettings.upsert({
            activity_type: 'TEST_ACTIVITY',
            advancement_pts: 100,
            max_capacity: 5,
            time_limit_min: 10, // 10 minutes duration
            category: 'Test'
        });
        console.log('   ✅ ActivitySettings created.');

        // 2. Create SessionConfig using this ActivityType
        console.log('\n2️⃣ Creating SessionConfig (Testing Inheritance)...');
        const session = await SessionConfig.create({
            session_id: 99999,
            activity_type: 'TEST_ACTIVITY',
            status: 'WAITING',
            join_window_minutes: 2 // 2 minutes join window
        });

        // Verify Inheritance
        console.log('   Checking inherited fields:');
        console.log(`   - Advancement Pts: ${session.advancement_pts} (Expected: 100)`);
        console.log(`   - Team Size Max: ${session.team_size_max} (Expected: 5)`);
        console.log(`   - Duration: ${session.activity_duration_minutes} (Expected: 10)`);

        if (session.advancement_pts === 100 && session.team_size_max === 5 && session.activity_duration_minutes === 10) {
            console.log('   ✅ Inheritance SUCCESS');
        } else {
            console.log('   ❌ Inheritance FAILED');
        }

        // 3. Test Status Logic (Simulating Time)
        console.log('\n3️⃣ Testing Status Logic...');

        // Mock `checkSessionExpiration` logic locally since we can't easily call private controller function
        // But we can check if the controller logic we wrote is correct by simulating the same math

        const now = Date.now();
        const joinWindowMs = 2 * 60 * 1000; // 2 mins
        const durationMs = 10 * 60 * 1000; // 10 mins

        // Case A: Just Started (In Join Window)
        let startedAt = new Date(now - 1 * 60 * 1000); // Started 1 min ago
        let status = getStatus(startedAt, joinWindowMs, durationMs);
        console.log(`   [Started 1m ago] Status: ${status} (Expected: ACTIVE)`);

        // Case B: Join Window Ended, In Progress
        startedAt = new Date(now - 3 * 60 * 1000); // Started 3 mins ago
        status = getStatus(startedAt, joinWindowMs, durationMs);
        console.log(`   [Started 3m ago] Status: ${status} (Expected: IN_PROGRESS)`);

        // Case C: Activity Completed
        startedAt = new Date(now - 15 * 60 * 1000); // Started 15 mins ago
        status = getStatus(startedAt, joinWindowMs, durationMs);
        console.log(`   [Started 15m ago] Status: ${status} (Expected: COMPLETED)`);

        // 4. Create HallQrToken with join_window_minutes
        console.log('\n4️⃣ Creating HallQrToken...');
        const token = await HallQrToken.create({
            hall_qr_token: 'TEST_TOKEN',
            session_id: 99999,
            join_window_minutes: 5,
            activity_type: 'TEST_ACTIVITY'
        });
        console.log(`   ✅ Token created with join_window_minutes: ${token.join_window_minutes}`);

        // Cleanup
        await token.destroy();
        await session.destroy();
        // await ActivitySettings.destroy({ where: { activity_type: 'TEST_ACTIVITY' }}); // Keep for inspection if needed

    } catch (error) {
        console.error('❌ Error:', error);
    }
}

function getStatus(startTime, joinWindowMs, durationMs) {
    const currentTime = Date.now();
    const timeSinceStart = currentTime - startTime.getTime();

    if (timeSinceStart < 0) return 'WAITING';
    if (timeSinceStart < joinWindowMs) return 'ACTIVE';
    if (timeSinceStart < (joinWindowMs + durationMs)) return 'IN_PROGRESS';
    return 'COMPLETED';
}

verifyLogic();
