// CWD: apps/api
const { PrismaClient } = require('./node_modules/@prisma/client');
const prisma = new PrismaClient();

async function run() {
    console.log('Fetching JWT secret...');
    require('dotenv').config();
    const jwt = require('./node_modules/jsonwebtoken');

    const secret = process.env.JWT_ACCESS_SECRET || 'mfoms2026-super-secret-key-for-dev';
    const user = await prisma.user.findFirst();
    if (!user) return console.log('NO USER');
    const payload = { sub: user.id, email: user.email, role: user.role };
    const token = jwt.sign(payload, secret, { expiresIn: '15m' });
    
    let cust = await prisma.customer.findFirst();
    
    console.log('Calling PATCH /api/customers/' + cust.id);
    const res = await fetch(`http://localhost:3001/api/customers/${cust.id}`, {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify({ fullName: cust.fullName + " Tested" })
    });

    console.log('Status:', res.status);
    console.log('Body:', await res.text());
}

run().catch(console.error).finally(() => prisma.$disconnect());
