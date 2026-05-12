const mysql = require("mysql2");

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  waitForConnections: true,
  connectionLimit: 10,
  ssl: {
    rejectUnauthorized: false,
  },
});

const db = pool.promise();

db.getConnection()
  .then((connection) => {
    console.log("✅ MySQL Railway Connected");
    connection.release();
  })
  .catch((err) => {
    console.log("❌ DB Error:", err.message);
  });

module.exports = db;