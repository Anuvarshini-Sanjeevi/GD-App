'use strict';
const { Model } = require('sequelize');
const bcrypt = require('bcryptjs');

module.exports = (sequelize, DataTypes) => {
    class Admin extends Model {
        static associate(models) {
            Admin.hasMany(models.HallQrToken, { foreignKey: 'created_by_admin_id' });
            Admin.hasMany(models.SessionConfig, { foreignKey: 'created_by_admin_id' });
            Admin.hasMany(models.QuestionBank, { foreignKey: 'admin_id' });
            Admin.hasMany(models.AdminAnalytics, { foreignKey: 'admin_id' });
            Admin.hasMany(models.AdminActivityLog, { foreignKey: 'admin_id' });
        }
    }
    Admin.init({
        admin_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        name: {
            type: DataTypes.STRING(255),
            allowNull: false
        },
        email: {
            type: DataTypes.STRING(255),
            allowNull: false,
            unique: true,
            validate: { isEmail: true }
        },
        password_hash: {
            type: DataTypes.STRING(255),
            allowNull: false
        },
        photo: DataTypes.TEXT,
        phone: DataTypes.STRING(20),
        is_active: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        },
        last_login: DataTypes.DATE
    }, {
        sequelize,
        modelName: 'Admin',
        tableName: 'Admins',
        underscored: true,
        hooks: {
            beforeCreate: async (admin) => {
                if (admin.password_hash) {
                    const salt = await bcrypt.genSalt(8);
                    admin.password_hash = await bcrypt.hash(admin.password_hash, salt);
                }
            },
            beforeUpdate: async (admin) => {
                if (admin.changed('password_hash')) {
                    const salt = await bcrypt.genSalt(8);
                    admin.password_hash = await bcrypt.hash(admin.password_hash, salt);
                }
            }
        }
    });
    return Admin;
};
