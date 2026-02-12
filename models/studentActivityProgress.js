'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class StudentActivityProgress extends Model {
        static associate(models) {
            StudentActivityProgress.belongsTo(models.User, { foreignKey: 'student_id' });
            StudentActivityProgress.belongsTo(models.ActivitySettings, { foreignKey: 'activity_type', targetKey: 'activity_type' });
        }
    }
    StudentActivityProgress.init({
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        student_id: {
            type: DataTypes.BIGINT,
            allowNull: false
        },
        activity_type: {
            type: DataTypes.STRING(50),
            allowNull: false
        },
        completed_levels: {
            type: DataTypes.INTEGER,
            defaultValue: 0
        }
    }, {
        sequelize,
        modelName: 'StudentActivityProgress',
        tableName: 'StudentActivityProgress',
        underscored: true
    });
    return StudentActivityProgress;
};
