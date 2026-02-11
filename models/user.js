'use strict';
const {
  Model
} = require('sequelize');
const bcrypt = require('bcryptjs');

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
      // define association here
    }
  }
  User.init({
    user_id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    photo: DataTypes.STRING(512),
    role: {
      type: DataTypes.ENUM('student', 'supervisor', 'admin'),
      allowNull: false,
      defaultValue: 'student'
    },
    current_level: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    credibility_history: DataTypes.JSON,
    streak: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    flags: DataTypes.JSON,
    phone: DataTypes.STRING(20),
    location: DataTypes.STRING(255),
    department: DataTypes.STRING(255),
    last_login: DataTypes.DATE
  }, {
    sequelize,
    modelName: 'User',
    hooks: {
      beforeCreate: async (user) => {
        if (user.password) {
          const salt = await bcrypt.genSalt(10);
          user.password = await bcrypt.hash(user.password, salt);
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('password')) {
          const salt = await bcrypt.genSalt(10);
          user.password = await bcrypt.hash(user.password, salt);
        }
      }
    }
  });
  return User;
};