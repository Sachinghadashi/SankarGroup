const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || 'nexus_secret_jwt_key_flutter_project_2026_super_secure!'
      );

      // Check database if available
      try {
        req.user = await User.findById(decoded.id).select('-password');
      } catch (e) {
        // Fallback for decoded token
        req.user = { id: decoded.id, email: decoded.email, role: decoded.role || 'user' };
      }

      if (!req.user) {
        req.user = { id: decoded.id, email: decoded.email, role: 'user' };
      }

      next();
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized, token failed verification',
      });
    }
  } else {
    return res.status(401).json({
      success: false,
      message: 'Not authorized, no bearer token provided',
    });
  }
};

module.exports = { protect };
