-- ============================================================
-- SQL-запросы и представления
-- ЛР №4 — Основы SQL. Запросы. Представления
-- ============================================================

-- 1. Вывести все строки таблицы
SELECT * FROM public."Uslugi";

-- 2. Изменённый порядок столбцов
SELECT "Stoimost", "Nazvanie", "Kod_uslugi" FROM public."Uslugi";

-- 3. WHERE с составным условием
SELECT * FROM public."Mastera"
WHERE "Spetsializatsiya" = 'Стилист' AND "Familya" = 'Смирнова';

-- 4. IN
SELECT * FROM public."Vizity"
WHERE "ID_mastera" IN (10, 12);

-- 5. BETWEEN
SELECT * FROM public."Uslugi"
WHERE "Stoimost" BETWEEN 800 AND 2000;

-- 6. LIKE
SELECT * FROM public."Uslugi"
WHERE "Nazvanie" LIKE 'Стриж%';

-- 7. Агрегатные функции
SELECT MAX("Stoimost") FROM public."Uslugi";
SELECT SUM("Obshchaya_stoimost") FROM public."Vizity";

-- 8. ORDER BY
SELECT * FROM public."Uslugi"
ORDER BY "Stoimost" DESC;

-- 9. GROUP BY + HAVING
SELECT "ID_mastera", COUNT(*) AS kolichestvo_vizitov
FROM public."Vizity"
GROUP BY "ID_mastera"
HAVING COUNT(*) > 1;

-- 10. JOIN
SELECT v."ID_vizita", k."Familya", m."Familya" AS master, u."Nazvanie", v."Obshchaya_stoimost"
FROM public."Vizity" v
JOIN public."Klienty" k ON v."ID_klienta" = k."ID_klienta"
JOIN public."Mastera" m ON v."ID_mastera" = m."ID_mastera"
JOIN public."Uslugi"  u ON v."Kod_uslugi" = u."Kod_uslugi";

-- 11. Подзапрос — единственное значение
SELECT * FROM public."Uslugi"
WHERE "Stoimost" > (SELECT AVG("Stoimost") FROM public."Uslugi");

-- 12. Подзапрос — множественные значения
SELECT * FROM public."Klienty"
WHERE "ID_klienta" IN (
    SELECT "ID_klienta" FROM public."Vizity"
    WHERE "Obshchaya_stoimost" > 1000
);

-- ============================================================
-- Представления (ЛР №4, часть 2)
-- ============================================================

-- Обновляемое представление
CREATE OR REPLACE VIEW view_klienty_telefon AS
SELECT "ID_klienta", "Familya", "Imya", "Telefon"
FROM public."Klienty";

-- Просмотр через представление
SELECT * FROM view_klienty_telefon;

-- Обновление через представление
UPDATE view_klienty_telefon
SET "Telefon" = '89009998877'
WHERE "ID_klienta" = 1;

-- Необновляемое представление (с агрегацией)
CREATE OR REPLACE VIEW view_cost_stats AS
SELECT "ID_mastera",
       COUNT(*)               AS vizity_count,
       SUM("Obshchaya_stoimost") AS total_sum,
       AVG("Obshchaya_stoimost") AS avg_sum
FROM public."Vizity"
GROUP BY "ID_mastera";

SELECT * FROM view_cost_stats;
