export const requireRole = (roles) => {  
    return (req, res, next) => {  
      // Example: Fetch user role from JWT or session  
      const userRole = req.user?.role;  
      if (!roles.includes(userRole)) {  
        return res.status(403).json({ error: 'Unauthorized' });  
      }  
      next();  
    };  
  };  
  
  // Usage in routes (e.g., only underwriting managers can create policies):  
  import { requireRole } from '../middleware/auth.js';  
  router.post('/policies', requireRole(['underwriting_manager']), async (req, res) => {  
    // ... policy creation logic  
  });  Vite