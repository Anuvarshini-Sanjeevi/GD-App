'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class ActivitySettings extends Model {
        static associate(models) {
            // No strict associations needed yet
        }
    }
    ActivitySettings.init({
        activity_type: {
            type: DataTypes.STRING(50),
            primaryKey: true,
            allowNull: false
        },
        advancement_pts: DataTypes.INTEGER,
        max_capacity: DataTypes.INTEGER,
        time_limit_min: DataTypes.INTEGER,
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
        modelName: 'ActivitySettings',
        tableName: 'ActivitySettings',
        underscored: true
    });
    return ActivitySettings;
};
