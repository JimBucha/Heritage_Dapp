import express from 'express';
import db from '../config/db.js';
import { requireRole } from '../middleware/auth.js';

const router = express.Router();

// Get all claims (Claims Manager only)
router.get('/', requireRole(['claims_manager']), async (req, res) => {
  try {
    const [claims] = await db.query(`
      SELECT c.*, u.full_name 
      FROM claims c
      JOIN users u ON c.user_id = u.user_id
    `);
    res.json(claims);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch claims' });
  }
});

// Update claim status
router.patch('/:id', requireRole(['claims_manager']), async (req, res) => {
  const { status } = req.body;
  try {
    await db.query('UPDATE claims SET status = ? WHERE claim_id = ?', [status, req.params.id]);
    res.json({ message: 'Claim updated' });
  } catch (error) {
    res.status(500).json({ error: 'Claim update failed' });
  }
});

export default router;