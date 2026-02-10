'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class AdminActivityLog extends Model {
        static associate(models) {
            AdminActivityLog.belongsTo(models.Admin, { foreignKey: 'admin_id' });
        }
    }
    AdminActivityLog.init({
        log_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        admin_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        action_type: {
            type: DataTypes.ENUM('LOGIN', 'CREATE_SESSION', 'UPDATE_CONFIG', 'DELETE_USER', 'EXPORT_DATA'),
            allowNull: false
        },
        session_id: DataTypes.INTEGER,
        details: DataTypes.JSON
    }, {
        sequelize,
        modelName: 'AdminActivityLog',
        tableName: 'AdminActivityLog',
        underscored: true
    });
    return AdminActivityLog;
};
