const express = require('express');
const router = express.Router();
const {
  getItems,
  getStats,
  getCategories,
  getItemById,
  createItem,
  updateItem,
  deleteItem,
} = require('../controllers/itemController');
const { protect } = require('../middleware/authMiddleware');

router.get('/stats', getStats);
router.get('/categories', getCategories);
router.get('/', getItems);
router.get('/:id', getItemById);
router.post('/', protect, createItem);
router.put('/:id', protect, updateItem);
router.delete('/:id', protect, deleteItem);

module.exports = router;
