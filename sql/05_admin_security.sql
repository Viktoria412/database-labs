-- ============================================================
-- Администрирование и защита БД
-- ЛР №7 — Информационные технологии
-- ============================================================

-- ----------------------------------------------------------
-- ТРАНЗАКЦИИ
-- ----------------------------------------------------------

-- Транзакция с ROLLBACK (откат)
BEGIN;

INSERT INTO public."Vizity" ("ID_vizita","Data_vremya","ID_klienta","ID_mastera","Obshchaya_stoimost","Kod_uslugi")
VALUES (100, '2025-05-01 10:00:00', 1, 10, 500, 100);

UPDATE public."Vizity"
SET "Obshchaya_stoimost" = 2000
WHERE "ID_vizita" = 1;

DELETE FROM public."Vizity"
WHERE "ID_vizita" = 2;

SELECT * FROM public."Vizity";

ROLLBACK;  -- отменяем все изменения

SELECT * FROM public."Vizity";  -- данные вернулись в исходное состояние

-- Транзакция с COMMIT (фиксация)
BEGIN;

INSERT INTO public."Vizity" ("ID_vizita","Data_vremya","ID_klienta","ID_mastera","Obshchaya_stoimost","Kod_uslugi")
VALUES (100, '2025-05-01 10:00:00', 1, 10, 500, 100);

UPDATE public."Vizity"
SET "Obshchaya_stoimost" = 2000
WHERE "ID_vizita" = 1;

DELETE FROM public."Vizity"
WHERE "ID_vizita" = 2;

COMMIT;  -- фиксируем изменения

SELECT * FROM public."Vizity";

-- ----------------------------------------------------------
-- УПРАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯМИ И ПРИВИЛЕГИЯМИ
-- ----------------------------------------------------------

-- Создать пользователя
CREATE USER barber_user WITH PASSWORD '12345';

-- Выдать привилегии SELECT, INSERT, UPDATE
GRANT SELECT, INSERT, UPDATE ON TABLE public."Uslugi" TO barber_user;

-- Проверить привилегии
SELECT * FROM public."Uslugi";

-- Попытка выполнить UPDATE от имени barber_user (должна пройти)
UPDATE public."Uslugi"
SET "Stoimost" = 900
WHERE "Kod_uslugi" = 101;

-- Отозвать UPDATE
REVOKE UPDATE ON TABLE public."Uslugi" FROM barber_user;

-- Теперь UPDATE от barber_user вызовет ошибку
UPDATE public."Uslugi"
SET "Stoimost" = 1000
WHERE "Kod_uslugi" = 101;

-- ----------------------------------------------------------
-- РЕЗЕРВНОЕ КОПИРОВАНИЕ (выполнять в терминале, не в psql)
-- ----------------------------------------------------------
-- Создать резервную копию:
--   pg_dump -U postgres -d postgres -F c -f barbershop_backup.dump
--
-- Восстановить:
--   pg_restore -U postgres -d postgres -F c barbershop_backup.dump

-- ----------------------------------------------------------
-- ИНДЕКСЫ И ПЛАН ВЫПОЛНЕНИЯ
-- ----------------------------------------------------------

-- Запрос БЕЗ индекса — смотрим план
EXPLAIN ANALYZE
SELECT * FROM public."Uslugi" WHERE "Stoimost" = 1500;

-- Создаём индекс
CREATE INDEX idx_stoimost ON public."Uslugi" ("Stoimost");

-- Запрос С индексом — план должен использовать Index Scan
EXPLAIN ANALYZE
SELECT * FROM public."Uslugi" WHERE "Stoimost" = 1500;
