# database-labs

Учебные лабораторные работы по дисциплине **«Информационные технологии»** — проектирование и реализация реляционной и документо-ориентированной баз данных.

**Предметная область:** Парикмахерская (клиенты, мастера, услуги, визиты)  
**СУБД:** PostgreSQL (реляционная), MongoDB (NoSQL)

---

## Структура репозитория

```
database-labs/
├── sql/
│   ├── 01_schema.sql              # DDL: создание таблиц и внешних ключей
│   ├── 02_seed_data.sql           # Тестовые данные
│   ├── 03_queries_views.sql       # SQL-запросы и представления (ЛР4)
│   ├── 04_procedures_triggers.sql # Хранимые процедуры, функции, триггеры (ЛР5)
│   └── 05_admin_security.sql      # Транзакции, пользователи, индексы (ЛР7)
├── nosql/
│   └── mongodb_queries.js         # MongoDB: запросы, агрегации, $lookup, пользователи (РЗ)
├── csharp/
│   ├── DBUtils.cs                 # Утилита подключения к PostgreSQL через Npgsql
│   └── Form1.cs                   # Windows Forms приложение для работы с БД (ЛР6)
└── cpp/
    ├── BarbershopQt.pro           # Qt project file
    ├── main.cpp                   # Точка входа
    ├── mainwindow.h               # Заголовочный файл (ЛР6)
    └── mainwindow.cpp             # Qt-приложение для работы с БД (ЛР6)
```

---

## Описание лабораторных работ

| Файл | ЛР | Тема |
|------|----|------|
| `01_schema.sql` | ЛР1–ЛР3 | ER-моделирование, DDL, CREATE TABLE, FOREIGN KEY |
| `02_seed_data.sql` | ЛР3 | Заполнение таблиц данными |
| `03_queries_views.sql` | ЛР4 | SELECT, WHERE, JOIN, GROUP BY, подзапросы, VIEW |
| `04_procedures_triggers.sql` | ЛР5 | PROCEDURE, FUNCTION, TRIGGER (INSERT/UPDATE/DELETE) |
| `05_admin_security.sql` | ЛР7 | TRANSACTION, COMMIT/ROLLBACK, GRANT/REVOKE, INDEX |
| `mongodb_queries.js` | РЗ | MongoDB: запросы, агрегации, $lookup, управление пользователями |
| `Form1.cs` + `DBUtils.cs` | ЛР6 | C# WinForms + Npgsql: подготовленные запросы, хранимые процедуры |
| `mainwindow.cpp/.h` | ЛР6 | C++ Qt + QPSQL: аналогичное приложение на Qt |

---

## Как запустить

### PostgreSQL (SQL-скрипты)

1. Установите [PostgreSQL](https://www.postgresql.org/download/)
2. Откройте pgAdmin или psql
3. Выполните файлы по порядку:
```sql
\i sql/01_schema.sql
\i sql/02_seed_data.sql
\i sql/03_queries_views.sql
-- и т.д.
```

### C# приложение

**Требования:** Visual Studio, пакет NuGet `Npgsql`

1. Создайте новый проект **Windows Forms App (.NET)**
2. Добавьте файлы `DBUtils.cs` и `Form1.cs`
3. Установите пакет: `Install-Package Npgsql`
4. В `DBUtils.cs` укажите свой пароль от PostgreSQL
5. Запустите проект

### C++ Qt приложение

**Требования:** Qt 5/6, драйвер QPSQL

1. Откройте `BarbershopQt.pro` в Qt Creator
2. В `mainwindow.cpp` укажите свой пароль:
   ```cpp
   db.setPassword("ваш_пароль");
   ```
3. Соберите и запустите (Build → Run)

### MongoDB (NoSQL / РЗ)

1. Установите [MongoDB](https://www.mongodb.com/try/download/community) и [MongoDB Compass](https://www.mongodb.com/products/compass)
2. Создайте БД `post_office` в Compass
3. Выполните запросы из `nosql/mongodb_queries.js` в Compass → Shell

---

## Технологии

`PostgreSQL` · `SQL` · `PL/pgSQL` · `C#` · `Npgsql` · `C++` · `Qt` · `MongoDB` · `NoSQL`
