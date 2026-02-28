const { Client } = require('pg');
const fs = require('fs');

const connectionString = 'postgresql://postgres:BZXBQbwYOmPMnUGkhiMOWRdPKuMMdENd@centerbeam.proxy.rlwy.net:18010/railway';

const client = new Client({
    connectionString: connectionString,
});

async function runSchema() {
    try {
        await client.connect();
        console.log('Connected to database.');
        const sql = fs.readFileSync('c:\\Users\\Administrator\\Desktop\\NaiCity\\database\\schema.sql', 'utf8');
        await client.query(sql);
        console.log('Schema executed successfully.');
    } catch (err) {
        console.error('Error executing schema:', err);
    } finally {
        await client.end();
    }
}

runSchema();
