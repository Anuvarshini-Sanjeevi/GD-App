'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    // 1. Admins Table
    await queryInterface.createTable('Admins', {
      admin_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      email: {
        type: Sequelize.STRING(255),
        allowNull: false,
        unique: true
      },
      password_hash: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      photo: {
        type: Sequelize.TEXT
      },
      phone: {
        type: Sequelize.STRING(20)
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      last_login: {
        type: Sequelize.DATE
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: { // Added automatically for Sequelize compatibility if needed, but schema only shows created_at. I'll add updated_at for standard compliance.
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // 2. Hall QR Tokens Table
    await queryInterface.createTable('HallQrTokens', {
      token_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      hall_qr_token: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      session_id: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      expires_in_minutes: {
        type: Sequelize.INTEGER
      },
      scan_count: {
        type: Sequelize.INTEGER,
        defaultValue: 0
      },
      created_by_admin_id: {
        type: Sequelize.INTEGER,
        references: {
          model: 'Admins',
          key: 'admin_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      status: {
        type: Sequelize.ENUM('ACTIVE', 'EXPIRED', 'DEACTIVATED'),
        defaultValue: 'ACTIVE'
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // 3. Session Configs Table
    await queryInterface.createTable('SessionConfigs', {
      config_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      session_id: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      team_size_min: {
        type: Sequelize.INTEGER
      },
      team_size_max: {
        type: Sequelize.INTEGER
      },
      join_window_minutes: {
        type: Sequelize.INTEGER
      },
      start_mode: {
        type: Sequelize.ENUM('MANUAL', 'AUTOMATIC', 'HYBRID'),
        defaultValue: 'MANUAL'
      },
      quorum_percent: {
        type: Sequelize.DECIMAL(4, 2)
      },
      activity_duration_minutes: {
        type: Sequelize.INTEGER
      },
      peer_eval_enabled: {
        type: Sequelize.BOOLEAN,
        defaultValue: false
      },
      quiz_enabled: {
        type: Sequelize.BOOLEAN,
        defaultValue: false
      },
      promotion_quota_base: {
        type: Sequelize.DECIMAL(5, 4)
      },
      supervisor_multipliers: {
        type: Sequelize.JSON
      },
      credibility_weights: {
        type: Sequelize.JSON
      },
      no_repeat_pairing_horizon: {
        type: Sequelize.INTEGER
      },
      created_by_admin_id: {
        type: Sequelize.INTEGER,
        references: {
          model: 'Admins',
          key: 'admin_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // 4. Question Bank Table
    await queryInterface.createTable('QuestionBank', {
      question_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      admin_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Admins',
          key: 'admin_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      session_id: {
        type: Sequelize.INTEGER
      },
      question_text: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      rank_count_r: {
        type: Sequelize.INTEGER
      },
      points_mapping: {
        type: Sequelize.JSON
      },
      active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // 5. Admin Analytics Table
    await queryInterface.createTable('AdminAnalytics', {
      analytic_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      admin_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Admins',
          key: 'admin_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      session_id: {
        type: Sequelize.INTEGER
      },
      analytic_type: {
        type: Sequelize.ENUM('SESSION_STATS', 'USER_PERFORMANCE', 'SYSTEM_HEALTH'),
        allowNull: false
      },
      data_json: {
        type: Sequelize.JSON,
        allowNull: false
      },
      generated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      created_at: { // Standardizing for Sequelize if needed
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // 6. Admin Activity Log Table
    await queryInterface.createTable('AdminActivityLog', {
      log_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      admin_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Admins',
          key: 'admin_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      action_type: {
        type: Sequelize.ENUM('LOGIN', 'CREATE_SESSION', 'UPDATE_CONFIG', 'DELETE_USER', 'EXPORT_DATA'),
        allowNull: false
      },
      session_id: {
        type: Sequelize.INTEGER
      },
      details: {
        type: Sequelize.JSON
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('AdminActivityLog');
    await queryInterface.dropTable('AdminAnalytics');
    await queryInterface.dropTable('QuestionBank');
    await queryInterface.dropTable('SessionConfigs');
    await queryInterface.dropTable('HallQrTokens');
    await queryInterface.dropTable('Admins');
  }
};
