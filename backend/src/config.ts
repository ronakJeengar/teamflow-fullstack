import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load .env from backend root
const envPath = join(__dirname, '../.env');
dotenv.config({ path: envPath });

// Validate required environment variables
const requiredEnvVars = [
    'JWT_ACCESS_SECRET',
    'JWT_REFRESH_SECRET',
    'DATABASE_URL'
];

for (const varName of requiredEnvVars) {
    if (!process.env[varName]) {
        throw new Error(`Missing required environment variable: ${varName}`);
    }
}

console.log('✅ Environment variables loaded successfully');

export const config = {
    jwtAccessSecret: process.env.JWT_ACCESS_SECRET!,
    jwtRefreshSecret: process.env.JWT_REFRESH_SECRET!,
    databaseUrl: process.env.DATABASE_URL!,
    port: process.env.PORT || '3000',
    nodeEnv: process.env.NODE_ENV || 'development',
};