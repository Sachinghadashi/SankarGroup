require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Item = require('./models/Item');

const initialItems = [
  {
    title: 'Sony WH-1000XM5 Wireless Headphones',
    description: 'Industry-leading noise cancellation with two processors and 8 microphones. Exceptional sound quality engineered with the new Integrated Processor V1, ultra-comfortable lightweight design, and crystal-clear hands-free calling.',
    price: 349.99,
    category: 'Electronics',
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80',
    rating: 4.8,
    reviewCount: 428,
    stock: 24,
    features: ['Active Noise Cancellation', '30-hour Battery Life', 'Multipoint Connection', 'Speak-to-Chat Technology'],
    isFeatured: true,
    tags: ['audio', 'wireless', 'bluetooth', 'music'],
  },
  {
    title: 'Ergonomic Mesh Executive Chair',
    description: 'Breathable high-back desk chair featuring dynamic lumbar support, 3D adjustable armrests, pneumatic seat height adjustment, and smooth rollerblade caster wheels. Ideal for work and gaming comfort.',
    price: 219.5,
    category: 'Furniture',
    imageUrl: 'https://images.unsplash.com/photo-1580481077195-c3a821a58875?auto=format&fit=crop&w=600&q=80',
    rating: 4.6,
    reviewCount: 185,
    stock: 12,
    features: ['Adaptive Lumbar Support', 'Breathable Mesh', 'Tilt Lock Mechanism', 'Heavy-duty Metal Base'],
    isFeatured: true,
    tags: ['office', 'chair', 'furniture', 'ergonomic'],
  },
  {
    title: 'Apple Watch Series 9 GPS + Cellular',
    description: 'Powerful S9 chip with Double Tap gesture control, brighter Always-On Retina display, fast charging, advanced heart rate tracking, ECG, and blood oxygen monitoring apps.',
    price: 429.0,
    category: 'Electronics',
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80',
    rating: 4.9,
    reviewCount: 612,
    stock: 18,
    features: ['S9 SiP with Double Tap gesture', 'Always-On Retina display', 'Water resistant to 50 meters', 'ECG and Blood Oxygen apps'],
    isFeatured: true,
    tags: ['smartwatch', 'apple', 'fitness', 'tech'],
  },
  {
    title: 'Full-Stack Cloud Consulting & DevOps',
    description: 'End-to-end architecture review, automated CI/CD pipeline implementation, Kubernetes cluster configuration, microservices scaling, and 24/7 reliability engineering.',
    price: 150.0,
    category: 'Services',
    imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=600&q=80',
    rating: 5.0,
    reviewCount: 74,
    stock: 5,
    features: ['AWS / GCP / Azure Architecture', 'Zero-downtime CI/CD', 'Docker & Kubernetes orchestration', 'Security hardening'],
    isFeatured: false,
    tags: ['devops', 'cloud', 'consulting', 'software'],
  },
  {
    title: 'Minimalist Scandinavian Solid Oak Desk',
    description: 'Crafted from sustainable European white oak with dual cable management slots, soft-close stationery drawer, and water-resistant matte satin protective finish.',
    price: 489.0,
    category: 'Furniture',
    imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=600&q=80',
    rating: 4.7,
    reviewCount: 92,
    stock: 8,
    features: ['100% Solid Natural Oak', 'Integrated Cable Channel', 'Matte Protective Finish', 'Easy 15-min Assembly'],
    isFeatured: true,
    tags: ['desk', 'wood', 'furniture', 'minimalist'],
  },
  {
    title: 'Vintage Leather Weekender Duffle Bag',
    description: 'Handcrafted top-grain distressed leather travel bag with reinforced brass hardware, dedicated shoe compartment, padded 15-inch laptop sleeve, and detachable shoulder strap.',
    price: 185.0,
    category: 'Fashion',
    imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80',
    rating: 4.8,
    reviewCount: 210,
    stock: 15,
    features: ['Top-grain Genuine Leather', 'Separate Shoe Compartment', 'Waterproof Nylon Lining', 'YKK Metal Zippers'],
    isFeatured: false,
    tags: ['bag', 'travel', 'leather', 'fashion'],
  },
  {
    title: 'Smart UV Air Purifier Pro',
    description: 'Medical-grade H13 True HEPA filter capturing 99.97% of airborne particles as small as 0.3 microns. Built-in air quality sensor, whisper-quiet sleep mode, and mobile app control.',
    price: 199.99,
    category: 'Health',
    imageUrl: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?auto=format&fit=crop&w=600&q=80',
    rating: 4.6,
    reviewCount: 144,
    stock: 20,
    features: ['H13 True HEPA Filter', 'Real-time PM2.5 display', 'UV-C sanitization light', 'Ultra-quiet 22dB operation'],
    isFeatured: true,
    tags: ['health', 'home', 'purifier', 'wellness'],
  },
  {
    title: 'Mobile App UI/UX & Design System Package',
    description: 'Full Figma interactive prototype, comprehensive design tokens, accessible color palettes, responsive component library, and ready-to-code design specs for iOS & Android.',
    price: 750.0,
    category: 'Services',
    imageUrl: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?auto=format&fit=crop&w=600&q=80',
    rating: 4.9,
    reviewCount: 56,
    stock: 3,
    features: ['Full Figma source files', 'Design token library', 'Interactive prototype', 'Developer handoff specs'],
    isFeatured: false,
    tags: ['design', 'ui', 'ux', 'mobile'],
  },
];

const seedData = async () => {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/project_flutter_db';
  console.log(`🌱 Connecting to MongoDB at ${uri}...`);

  try {
    await mongoose.connect(uri);
    console.log('✅ Connected to MongoDB. Seeding database collections...');

    // Clear existing collections
    await User.deleteMany({});
    await Item.deleteMany({});
    console.log('🗑️ Cleared existing Users and Items collections in MongoDB');

    // Create demo users in MongoDB
    const adminUser = await User.create({
      name: 'Sachin Ghadashi',
      email: 'admin@example.com',
      password: 'password123',
      role: 'admin',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    });

    const regularUser = await User.create({
      name: 'Demo Customer',
      email: 'user@example.com',
      password: 'password123',
      role: 'user',
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
    });

    console.log(`👤 Seeded 2 users in MongoDB:`);
    console.log(`   - ${adminUser.email} / password123 (Admin)`);
    console.log(`   - ${regularUser.email} / password123 (User)`);

    // Insert items into MongoDB
    const insertedItems = await Item.insertMany(initialItems);
    console.log(`📦 Seeded ${insertedItems.length} products & services directly into MongoDB!`);

    await mongoose.connection.close();
    console.log('✨ MongoDB seeding completed successfully.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during seeding:', error.message);
    process.exit(1);
  }
};

seedData();
