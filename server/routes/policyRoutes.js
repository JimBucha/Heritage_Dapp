import express from 'express';
import db from '../config/db.js';

const router = express.Router();

// Get all policies
router.get('/policies', async (req, res) => {
  try {
    const [policies] = await db.query('SELECT * FROM policies');
    res.json(policies);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch policies' });
  }
});

// Create new policy (called by underwriting manager)
router.post('/policies', async (req, res) => {
  const { name, category_id, ipfs_hash } = req.body;
  try {
    await db.query(
      'INSERT INTO policies (name, category_id, ipfs_hash, created_by) VALUES (?, ?, ?, ?)',
      [name, category_id, ipfs_hash, req.user.user_id]
    );
    res.status(201).json({ message: 'Policy created' });
  } catch (error) {
    res.status(500).json({ error: 'Policy creation failed' });
  }
});

export default router;