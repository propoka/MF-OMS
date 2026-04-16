const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const jwt = require('jsonwebtoken');

(async () => {
    try {
        const user = await prisma.user.findFirst();
        if (!user) return console.log('NO USER');
        
        const payload = { sub: user.id, email: user.email, role: user.role };
        const secret = process.env.JWT_ACCESS_SECRET || 'mfoms2026-super-secret-key-for-dev';
        const token = jwt.sign(payload, secret, { expiresIn: '15m' });
        
        let customer = await prisma.customer.findFirst();
        if (!customer) {
            customer = await prisma.customer.create({
                data: {
                    fullName: 'Test Customer',
                    code: 'KH99999',
                    groupId: (await prisma.customerGroup.findFirst()).id
                }
            });
        }
        
        console.log('Sending PATCH request...');
        const res = await fetch('http://localhost:3001/api/customers/' + customer.id, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ fullName: customer.fullName + ' Valid' })
        });
        
        console.log('Status: ', res.status);
        console.log('Body: ', await res.text());
        
    } catch (e) {
        console.log(e);
    } finally {
        await prisma.$disconnect();
    }
})();
