-- ============================================================
-- Хранимые процедуры, функции и триггеры
-- ЛР №5 — Информационные технологии
-- ============================================================

-- ----------------------------------------------------------
-- ПРОЦЕДУРЫ
-- ----------------------------------------------------------

-- Процедура: создать нового клиента и сразу записать на визит
CREATE OR REPLACE PROCEDURE new_client_with_visit (
  p_Familya       VARCHAR(30),
  p_Imya          VARCHAR(30),
  p_Otchestvo     VARCHAR(30),
  p_Telefon       VARCHAR(30),
  p_ID_klienta    INT,
  p_ID_mastera    INT,
  p_Kod_uslugi    INT,
  p_ID_vizita     INT,
  p_Data_vremya   TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_stoimost DECIMAL(10,2);
BEGIN
    INSERT INTO public."Klienty" ("ID_klienta","Familya","Imya","Otchestvo","Telefon")
    VALUES (p_ID_klienta, p_Familya, p_Imya, p_Otchestvo, p_Telefon);

    SELECT "Stoimost" INTO v_stoimost
    FROM public."Uslugi"
    WHERE "Kod_uslugi" = p_Kod_uslugi;

    INSERT INTO public."Vizity" ("ID_vizita","Data_vremya","ID_klienta","ID_mastera","Obshchaya_stoimost","Kod_uslugi")
    VALUES (p_ID_vizita, p_Data_vremya, p_ID_klienta, p_ID_mastera, v_stoimost, p_Kod_uslugi);

    RAISE NOTICE 'Создан клиент: % % % (ID: %) с записью к мастеру ID: % на %',
        p_Familya, p_Imya, p_Otchestvo, p_ID_klienta, p_ID_mastera, p_Data_vremya;
END;
$$;

-- Вызов процедуры
CALL new_client_with_visit('Волков','Алексей','Николаевич','89001234567',
                            10, 10, 100, 20, '2025-04-20 14:00:00');

-- ----------------------------------------------------------
-- ФУНКЦИИ
-- ----------------------------------------------------------

-- Функция: посчитать суммарную стоимость всех визитов клиента
CREATE OR REPLACE FUNCTION total_client_cost (p_id_klienta INT)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
  v_total_cost DECIMAL := 0;
BEGIN
    SELECT COALESCE(SUM("Obshchaya_stoimost"), 0)
    INTO v_total_cost
    FROM public."Vizity"
    WHERE "ID_klienta" = p_id_klienta;
    RETURN v_total_cost;
END;
$$;

SELECT total_client_cost(1);
SELECT total_client_cost(2);

-- ----------------------------------------------------------
-- ТРИГГЕРЫ
-- ----------------------------------------------------------

-- Триггер INSERT: запрет добавления услуги с некорректной стоимостью
CREATE OR REPLACE FUNCTION check_service_price()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."Stoimost" <= 0 THEN
        RAISE EXCEPTION 'Стоимость услуги должна быть положительной (указано: %)', NEW."Stoimost";
    END IF;
    IF NEW."Stoimost" > 10000 THEN
        RAISE EXCEPTION 'Стоимость не может превышать 10000 руб. (указано: %)', NEW."Stoimost";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_service_price
BEFORE INSERT ON public."Uslugi"
FOR EACH ROW EXECUTE FUNCTION check_service_price();

-- Тест триггера
INSERT INTO public."Uslugi" ("Kod_uslugi", "Nazvanie", "Stoimost") VALUES (200, 'Тест', -500);   -- ошибка
INSERT INTO public."Uslugi" ("Kod_uslugi", "Nazvanie", "Stoimost") VALUES (201, 'VIP', 15000);   -- ошибка
INSERT INTO public."Uslugi" ("Kod_uslugi", "Nazvanie", "Stoimost") VALUES (104, 'Стрижка детская', 600); -- ОК

-- Триггер UPDATE/DELETE: нельзя удалить/изменить мастера, у которого есть визиты
CREATE OR REPLACE FUNCTION check_master_visits()
RETURNS TRIGGER AS $$
DECLARE
  v_visit_count INT;
BEGIN
    SELECT COUNT(*) INTO v_visit_count
    FROM public."Vizity"
    WHERE "ID_mastera" = OLD."ID_mastera";

    IF v_visit_count > 0 THEN
        RAISE EXCEPTION 'Нельзя удалить/изменить мастера ID: %. У него % визит(а/ов). Сначала удалите визиты.',
            OLD."ID_mastera", v_visit_count;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_master_visits
BEFORE DELETE OR UPDATE ON public."Mastera"
FOR EACH ROW EXECUTE FUNCTION check_master_visits();

-- Тест: попытка удалить мастера с визитами (ошибка)
DELETE FROM public."Mastera" WHERE "ID_mastera" = 10;
-- Успешное удаление мастера без визитов
DELETE FROM public."Mastera" WHERE "ID_mastera" = 13;

-- Триггер INSERT: автоматически подставить стоимость визита из таблицы услуг
CREATE OR REPLACE FUNCTION calculate_visit_cost()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."Obshchaya_stoimost" IS NULL THEN
        SELECT "Stoimost" INTO NEW."Obshchaya_stoimost"
        FROM public."Uslugi"
        WHERE "Kod_uslugi" = NEW."Kod_uslugi";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_visit_cost
BEFORE INSERT ON public."Vizity"
FOR EACH ROW EXECUTE FUNCTION calculate_visit_cost();
