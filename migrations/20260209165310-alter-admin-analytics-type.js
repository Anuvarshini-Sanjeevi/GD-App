'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.changeColumn('AdminAnalytics', 'analytic_type', {
      type: Sequelize.STRING(100),
      allowNull: false
    });
  },

  async down(queryInterface, Sequelize) {
    // Reverting to the original ENUM if needed, but STRING is safer
    await queryInterface.changeColumn('AdminAnalytics', 'analytic_type', {
      type: Sequelize.ENUM('SESSION_STATS', 'USER_PERFORMANCE', 'SYSTEM_HEALTH'),
      allowNull: false
    });
  }
};
