'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class StudentRanking extends Model {
        static associate(models) {
            // Define association to User
            StudentRanking.belongsTo(models.User, { foreignKey: 'student_id', targetKey: 'user_id' });
        }
    }
    StudentRanking.init({
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        student_id: {
            type: DataTypes.BIGINT,
            allowNull: true
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false
        },
        photo: DataTypes.STRING(512),
        activity_type: {
            type: DataTypes.STRING(50),
            allowNull: false,
            defaultValue: 'GROUP_DISCUSSION'
        },
        level: {
            type: DataTypes.STRING(50),
            allowNull: false,
            defaultValue: 'OVERALL'
        },
        rank: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        points: {
            type: DataTypes.INTEGER,
            defaultValue: 0
        },
        trend: {
            type: DataTypes.STRING(20),
            defaultValue: 'SAME'
        }
    }, {
        sequelize,
        modelName: 'StudentRanking',
        tableName: 'StudentRankings',
        underscored: true
    });
    return StudentRanking;
};
