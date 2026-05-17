const mysql = require("mysql2");
require("dotenv").config();

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT) || 3306,

  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,

  enableKeepAlive: true,
  keepAliveInitialDelay: 0,

  ssl: {
    rejectUnauthorized: false,
  },
});

const db = pool.promise();

db.getConnection()
  .then((connection) => {
    console.log("✅ MySQL Connected");
    connection.release();
  })
  .catch((err) => {
    console.log("❌ DB Error:", err.message);
  });

module.exports = db;