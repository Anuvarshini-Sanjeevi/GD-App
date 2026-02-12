const db = require('./models');
const { SessionConfig } = db;

const checkSessionExpiration = (session) => {
    if (session.status === 'ACTIVE' && session.started_at && (session.activity_duration_minutes !== null && session.activity_duration_minutes !== undefined)) {
        const startTime = new Date(session.started_at).getTime();
        const currentTime = new Date().getTime();
        const durationMs = session.activity_duration_minutes * 60 * 1000;

        console.log(`Checking expiration: Start=${startTime}, Now=${currentTime}, DurationMs=${durationMs}, Diff=${currentTime - startTime}`);

        if (currentTime - startTime >= durationMs) {
            console.log('Session EXPIRED! Setting to INACTIVE');
            return 'INACTIVE';
        }
    }
    return session.status;
};

async function test() {
    const startedAt = new Date(Date.now() - 70000); // 70 seconds ago
    const session = {
        status: 'ACTIVE',
        started_at: startedAt,
        activity_duration_minutes: 1
    };

    console.log('Testing session started 70s ago with 1min limit...');
    const result = checkSessionExpiration(session);
    console.log('Result status:', result);

    if (result === 'INACTIVE') {
        console.log('Unit test SUCCESS');
    } else {
        console.log('Unit test FAILURE');
    }
}

test();
