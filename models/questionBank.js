'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class QuestionBank extends Model {
        static associate(models) {
            QuestionBank.belongsTo(models.Admin, { foreignKey: 'admin_id' });
        }
    }
    QuestionBank.init({
        question_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        admin_id: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        session_id: DataTypes.INTEGER,
        question_text: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        rank_count_r: DataTypes.INTEGER,
        points_mapping: DataTypes.JSON,
        active: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        }
    }, {
        sequelize,
        modelName: 'QuestionBank',
        tableName: 'QuestionBank',
        underscored: true
    });
    return QuestionBank;
};
