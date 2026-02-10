'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Users', {
      user_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.BIGINT
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false
      },
      email: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true
      },
      password: {
        type: Sequelize.STRING,
        allowNull: false
      },
      photo: {
        type: Sequelize.STRING(512)
      },
      role: {
        type: Sequelize.ENUM('student', 'supervisor', 'admin'),
        allowNull: false,
        defaultValue: 'student'
      },
      current_level: {
        type: Sequelize.INTEGER,
        defaultValue: 0
      },
      credibility_history: {
        type: Sequelize.JSON
      },
      streak: {
        type: Sequelize.INTEGER,
        defaultValue: 0
      },
      flags: {
        type: Sequelize.JSON
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Users');
  }
};