const bcrypt = require('bcryptjs');

module.exports = {
  async up(queryInterface, Sequelize) {
    // Clear existing user with same email if needed
    await queryInterface.bulkDelete('Users', { email: 'admin@example.com' }, {});

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('password123', salt);

    return queryInterface.bulkInsert('Users', [{
      name: 'Initial Admin',
      email: 'admin@example.com',
      password: hashedPassword,
      role: 'admin',
      phone: 'Not Provided',
      location: 'Headquarters',
      department: 'Computer Science & Engineering',
      createdAt: new Date(),
      updatedAt: new Date()
    }]);
  },

  async down(queryInterface, Sequelize) {
    return queryInterface.bulkDelete('Users', null, {});
  }
};
