const jwt = require("jsonwebtoken");

const protect = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    // 1) Vérifier si header existe
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ message: "Accès refusé, token manquant" });
    }

    // 2) Extraire token
    const token = authHeader.split(" ")[1];

    // 3) Vérifier token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 4) Sauvegarder infos user dans req.user
    req.user = decoded;

    next();
  } catch (err) {
    return res.status(401).json({ message: "Token invalide ou expiré" });
  }
};

// middleware pour rôles
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: "Accès interdit (role)" });
    }
    next();
  };
};

module.exports = { protect, authorize };