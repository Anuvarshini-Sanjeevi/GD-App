'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class SessionConfig extends Model {
        static associate(models) {
            SessionConfig.belongsTo(models.Admin, { foreignKey: 'created_by_admin_id' });
        }
    }
    SessionConfig.init({
        config_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        session_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        team_size_min: DataTypes.INTEGER,
        team_size_max: DataTypes.INTEGER,
        join_window_minutes: DataTypes.INTEGER,
        start_mode: {
            type: DataTypes.ENUM('MANUAL', 'AUTOMATIC', 'HYBRID'),
            defaultValue: 'MANUAL'
        },
        quorum_percent: DataTypes.DECIMAL(4, 2),
        activity_duration_minutes: DataTypes.INTEGER,
        peer_eval_enabled: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        quiz_enabled: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        promotion_quota_base: DataTypes.DECIMAL(5, 4),
        supervisor_multipliers: DataTypes.JSON,
        credibility_weights: DataTypes.JSON,
        no_repeat_pairing_horizon: DataTypes.INTEGER,
        created_by_admin_id: DataTypes.INTEGER,
        status: {
            type: DataTypes.ENUM('WAITING', 'ACTIVE', 'COMPLETED', 'CANCELLED'),
            defaultValue: 'WAITING'
        },
        activity_type: DataTypes.STRING(50),
        advancement_pts: DataTypes.INTEGER,
        cool_down_sec: DataTypes.INTEGER,
        weight_technical: DataTypes.INTEGER,
        weight_communication: DataTypes.INTEGER,
        weight_synergy: DataTypes.INTEGER,
        auto_rewards: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        },
        intel_feedback: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        }
    }, {
        sequelize,
        modelName: 'SessionConfig',
        tableName: 'SessionConfigs',
        underscored: true
    });
    return SessionConfig;
};
