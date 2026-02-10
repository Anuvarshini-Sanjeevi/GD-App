'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class HallQrToken extends Model {
        static associate(models) {
            HallQrToken.belongsTo(models.Admin, { foreignKey: 'created_by_admin_id' });
        }
    }
    HallQrToken.init({
        token_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        hall_qr_token: {
            type: DataTypes.STRING(255),
            allowNull: false
        },
        session_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        expires_in_minutes: DataTypes.INTEGER,
        scan_count: {
            type: DataTypes.INTEGER,
            defaultValue: 0
        },
        created_by_admin_id: DataTypes.INTEGER,
        status: {
            type: DataTypes.ENUM('ACTIVE', 'EXPIRED', 'DEACTIVATED'),
            defaultValue: 'ACTIVE'
        }
    }, {
        sequelize,
        modelName: 'HallQrToken',
        tableName: 'HallQrTokens',
        underscored: true
    });
    return HallQrToken;
};
