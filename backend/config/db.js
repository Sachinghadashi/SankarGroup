const mongoose = require('mongoose');

const connectDB = async () => {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/project_flutter_db';

  try {
    const conn = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 5000,
    });
    console.log(`✅ [MongoDB] Connected to database: ${conn.connection.name} @ ${conn.connection.host}`);
    return conn;
  } catch (error) {
    console.error(`❌ [MongoDB] Database connection error: ${error.message}`);
    console.error(`   Ensure MongoDB (local or MongoDB Atlas) is running and your connection string in backend/.env is correct.`);
    return null;
  }
};

module.exports = connectDB;
