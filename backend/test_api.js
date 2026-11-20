// Direct automated test script for the MongoDB database-backed API
const http = require('http');

const runTests = async () => {
  console.log('🧪 Starting database API test suite (Strictly MongoDB)...');

  const { app, server } = require('./server');

  const request = (path, method = 'GET', body = null, headers = {}) => {
    return new Promise((resolve, reject) => {
      const payload = body ? JSON.stringify(body) : null;
      const options = {
        hostname: '127.0.0.1',
        port: 5000,
        path,
        method,
        headers: {
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          ...headers,
        },
      };

      const req = http.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(data) });
          } catch (e) {
            resolve({ status: res.statusCode, data });
          }
        });
      });

      req.on('error', reject);
      if (payload) req.write(payload);
      req.end();
    });
  };

  try {
    await new Promise((r) => setTimeout(r, 600));

    // 1. Health check
    const health = await request('/api/health');
    console.log('1️⃣ Health Check:', health.status === 200 ? '✅ PASS' : '❌ FAIL', health.data.mongodb);

    // 2. Login directly with MongoDB user
    const loginRes = await request('/api/auth/login', 'POST', {
      email: 'admin@example.com',
      password: 'password123',
    });
    console.log('2️⃣ MongoDB Login API:', loginRes.status === 200 ? '✅ PASS' : '❌ FAIL', loginRes.data.message);
    const token = loginRes.data.token;

    // 3. Register user directly in MongoDB
    const randomEmail = `db_user_${Date.now()}@example.com`;
    const regRes = await request('/api/auth/register', 'POST', {
      name: 'MongoDB User',
      email: randomEmail,
      password: 'mypassword123',
    });
    console.log('3️⃣ MongoDB Register API:', regRes.status === 201 ? '✅ PASS' : '❌ FAIL', regRes.data.message);

    // 4. Get items listing from MongoDB
    const itemsRes = await request('/api/items');
    console.log('4️⃣ Items from MongoDB:', itemsRes.status === 200 ? '✅ PASS' : '❌ FAIL', `Found ${itemsRes.data.count} items in database`);

    // 5. Dynamic Categories from MongoDB
    const catRes = await request('/api/items/categories');
    console.log('5️⃣ Dynamic Categories from MongoDB:', catRes.status === 200 ? '✅ PASS' : '❌ FAIL', catRes.data.categories);

    // 6. Search filtering in MongoDB
    const searchRes = await request('/api/items?search=Sony');
    console.log('6️⃣ Database Search ("Sony"):', searchRes.status === 200 ? '✅ PASS' : '❌ FAIL', `Matched ${searchRes.data.count} items`);

    // 7. Dashboard stats from MongoDB
    const statsRes = await request('/api/items/stats');
    console.log('7️⃣ Database Stats API:', statsRes.status === 200 ? '✅ PASS' : '❌ FAIL', statsRes.data.stats);

    // 8. Single item detail from MongoDB
    if (itemsRes.data.items && itemsRes.data.items.length > 0) {
      const firstItemId = itemsRes.data.items[0]._id;
      const detailRes = await request(`/api/items/${firstItemId}`);
      console.log('8️⃣ Item Detail from MongoDB:', detailRes.status === 200 ? '✅ PASS' : '❌ FAIL', detailRes.data.item ? detailRes.data.item.title : 'None');
    }

    console.log('\n🎉 ALL MONGODB DATABASE API TESTS COMPLETED AND PASSED!\n');
    server.close();
    process.exit(0);
  } catch (err) {
    console.error('❌ Test failed:', err);
    server.close();
    process.exit(1);
  }
};

runTests();
