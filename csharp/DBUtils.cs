using System;
using Npgsql;

namespace BarbershopApp
{
    /// <summary>
    /// Утилита подключения к PostgreSQL.
    /// ЛР №6 — Технологии доступа к базам данных.
    /// </summary>
    internal class DBUtils
    {
        public static NpgsqlConnection GetDBConnection()
        {
            string host             = "localhost";
            string database         = "postgres";
            string username         = "postgres";
            string password         = "123";           // поменяйте на свой пароль
            string connectionString = $"Server={host};Port=5432;Database={database};User Id={username};Password={password}";
            return new NpgsqlConnection(connectionString);
        }
    }
}
