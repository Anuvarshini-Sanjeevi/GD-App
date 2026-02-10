'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class AdminAnalytics extends Model {
        static associate(models) {
            AdminAnalytics.belongsTo(models.Admin, { foreignKey: 'admin_id' });
        }
    }
    AdminAnalytics.init({
        analytic_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        admin_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        session_id: DataTypes.INTEGER,
        analytic_type: {
            type: DataTypes.STRING(100),
            allowNull: false
        },
        data_json: {
            type: DataTypes.JSON,
            allowNull: false
        },
        generated_at: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW
        }
    }, {
        sequelize,
        modelName: 'AdminAnalytics',
        tableName: 'AdminAnalytics',
        underscored: true
    });
    return AdminAnalytics;
};
