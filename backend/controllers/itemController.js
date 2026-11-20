const Item = require('../models/Item');

// @desc    Get all items with search, filter, and sort directly from MongoDB
// @route   GET /api/items
// @access  Public
exports.getItems = async (req, res) => {
  try {
    const { search, category, sortBy, limit } = req.query;
    let query = {};

    if (category && category !== 'All') {
      query.category = category;
    }

    if (search && search.trim() !== '') {
      const searchRegex = { $regex: search.trim(), $options: 'i' };
      query.$or = [
        { title: searchRegex },
        { description: searchRegex },
        { tags: { $in: [new RegExp(search.trim(), 'i')] } },
      ];
    }

    let sortOptions = { createdAt: -1 };
    if (sortBy === 'price_asc') sortOptions = { price: 1 };
    else if (sortBy === 'price_desc') sortOptions = { price: -1 };
    else if (sortBy === 'rating') sortOptions = { rating: -1 };
    else if (sortBy === 'popular') sortOptions = { reviewCount: -1 };

    const itemsQuery = Item.find(query).sort(sortOptions);
    if (limit) itemsQuery.limit(parseInt(limit));

    const items = await itemsQuery;

    return res.status(200).json({
      success: true,
      count: items.length,
      items,
    });
  } catch (error) {
    console.error('Error fetching items from database:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Database error fetching items',
    });
  }
};

// @desc    Get distinct categories dynamically from MongoDB
// @route   GET /api/items/categories
// @access  Public
exports.getCategories = async (req, res) => {
  try {
    const dbCategories = await Item.distinct('category');
    return res.status(200).json({
      success: true,
      categories: ['All', ...dbCategories],
    });
  } catch (error) {
    console.error('Error fetching categories from database:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Database error fetching categories',
    });
  }
};

// @desc    Get dashboard metrics / stats dynamically from MongoDB
// @route   GET /api/items/stats
// @access  Public
exports.getStats = async (req, res) => {
  try {
    const totalItems = await Item.countDocuments();
    const featuredItems = await Item.countDocuments({ isFeatured: true });
    const categories = await Item.distinct('category');
    const ratings = await Item.aggregate([
      { $group: { _id: null, avgRating: { $avg: '$rating' } } },
    ]);
    const avgRating = ratings[0] ? ratings[0].avgRating.toFixed(1) : '0.0';

    return res.status(200).json({
      success: true,
      stats: {
        totalItems,
        totalCategories: categories.length,
        featuredItems,
        averageRating: parseFloat(avgRating),
      },
    });
  } catch (error) {
    console.error('Error calculating stats from database:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Database error calculating stats',
    });
  }
};

// @desc    Get single item by ID from MongoDB
// @route   GET /api/items/:id
// @access  Public
exports.getItemById = async (req, res) => {
  try {
    const { id } = req.params;
    const item = await Item.findById(id);

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found in database',
      });
    }

    return res.status(200).json({
      success: true,
      item,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Database error fetching item',
    });
  }
};

// @desc    Create new item in MongoDB
// @route   POST /api/items
// @access  Private
exports.createItem = async (req, res) => {
  try {
    const { title, description, price, category } = req.body;

    if (!title || !description || !price || !category) {
      return res.status(400).json({
        success: false,
        message: 'Please provide title, description, price, and category',
      });
    }

    const item = await Item.create(req.body);
    return res.status(201).json({
      success: true,
      message: 'Item saved to database successfully',
      item,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Database error creating item',
    });
  }
};

// @desc    Update item in MongoDB
// @route   PUT /api/items/:id
// @access  Private
exports.updateItem = async (req, res) => {
  try {
    const { id } = req.params;
    const item = await Item.findByIdAndUpdate(id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found in database',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Item updated in database successfully',
      item,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Database error updating item',
    });
  }
};

// @desc    Delete item from MongoDB
// @route   DELETE /api/items/:id
// @access  Private
exports.deleteItem = async (req, res) => {
  try {
    const { id } = req.params;
    const item = await Item.findByIdAndDelete(id);

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found in database',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Item removed from database successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Database error deleting item',
    });
  }
};
