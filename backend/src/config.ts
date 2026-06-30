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
    'DATABASE_URL',
    'JWT_ACCESS_SECRET',
    'JWT_REFRESH_SECRET',
    'CORS_ORIGIN',
    'COOKIE_SECRET'
];

for (const varName of requiredEnvVars) {
    if (!process.env[varName]) {
        throw new Error(`CRITICAL STARTUP ERROR: Missing required environment variable: ${varName}`);
    }
}

console.log('✅ Environment variables validated successfully');

export const config = {
    jwtAccessSecret: process.env.JWT_ACCESS_SECRET!,
    jwtRefreshSecret: process.env.JWT_REFRESH_SECRET!,
    databaseUrl: process.env.DATABASE_URL!,
    corsOrigin: process.env.CORS_ORIGIN!,
    cookieSecret: process.env.COOKIE_SECRET!,
    port: process.env.PORT || '5000',
    nodeEnv: process.env.NODE_ENV || 'production',
};