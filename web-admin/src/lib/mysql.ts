import 'server-only';
import type tls from 'node:tls';
import mysql from 'mysql2/promise';

/**
 * Single MySQL connection pool for the whole app (server-side only).
 * Reads connection settings from environment variables.
 */

function readEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

declare global {
  // Reuse the pool across hot reloads in development.
  var __cjMysqlPool: mysql.Pool | undefined;
}

export function getPool(): mysql.Pool {
  if (!globalThis.__cjMysqlPool) {
    // TiDB Cloud requires a TLS connection. Enable SSL when MYSQL_SSL=true
    // (set it for TiDB; leave unset/false for local MySQL).
    const useSsl = (process.env.MYSQL_SSL ?? 'false').toLowerCase() === 'true';

    // mysql2 forwards these options to Node's TLS layer, which accepts
    // `servername` (SNI). mysql2's own `SslOptions` type omits it, so build
    // the object with the broader TLS type and cast when assigning. TiDB
    // Cloud needs the SNI set to the host, otherwise the handshake drops the
    // password and auth fails ("password: NO").
    const sslOptions = useSsl
      ? ({
          minVersion: 'TLSv1.2',
          rejectUnauthorized: true,
          servername: readEnv('MYSQL_HOST'),
        } satisfies tls.ConnectionOptions as mysql.PoolOptions['ssl'])
      : undefined;

    globalThis.__cjMysqlPool = mysql.createPool({
      host: readEnv('MYSQL_HOST'),
      port: Number(process.env.MYSQL_PORT ?? '3306'),
      user: readEnv('MYSQL_USER'),
      password: readEnv('MYSQL_PASSWORD'),
      database: readEnv('MYSQL_DATABASE'),
      waitForConnections: true,
      connectionLimit: 10,
      namedPlaceholders: false,
      ssl: sslOptions,
    });
  }
  return globalThis.__cjMysqlPool;
}
