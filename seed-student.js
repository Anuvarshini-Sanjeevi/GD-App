const db = require('./models');

async function seedStudent() {
    try {
        const studentData = {
            name: 'Prakalya',
            email: 'prakalya@example.com',
            password: 'password123',
            role: 'student',
            roll_number: 'STU002',
            batch: '2024',
            department: 'Computer Science',
            current_level: 1
        };

        console.log('Checking if student exists...');
        const existing = await db.User.findOne({ where: { email: studentData.email } });

        if (existing) {
            console.log('Student with this email already exists.');
            return;
        }

        console.log('Creating student...');
        const user = await db.User.create(studentData);
        console.log('Student created successfully!');
        console.log('Email:', user.email);
        console.log('Password: password123 (Before hashing)');

    } catch (error) {
        console.error('Error creating student:', error.message);
    } finally {
        await db.sequelize.close();
    }
}

seedStudent();
