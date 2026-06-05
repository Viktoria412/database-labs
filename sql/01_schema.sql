-- ============================================================
-- БД: Парикмахерская (barbershop)
-- Дисциплина: Информационные технологии
-- ЛР №3 — Построение реляционной БД
-- ============================================================

-- Таблица Клиенты
CREATE TABLE "Klienty"
(
  "ID_klienta"  Int         NOT NULL,
  "Familya"     Varchar(30),
  "Imya"        Varchar(30),
  "Otchestvo"   Varchar(30),
  "Telefon"     Varchar(30),
  CONSTRAINT "PK_Klienty" PRIMARY KEY ("ID_klienta")
);

-- Таблица Мастера
CREATE TABLE "Mastera"
(
  "ID_mastera"       Int         NOT NULL,
  "Familya"          Varchar(30),
  "Imya"             Varchar(30),
  "Otchestvo"        Varchar(30),
  "Spetsializatsiya" Varchar(30),
  CONSTRAINT "PK_Mastera" PRIMARY KEY ("ID_mastera")
);

-- Таблица Услуги
CREATE TABLE "Uslugi"
(
  "Kod_uslugi" Int          NOT NULL,
  "Nazvanie"   Varchar(30),
  "Stoimost"   Decimal(38,0),
  CONSTRAINT "PK_Uslugi" PRIMARY KEY ("Kod_uslugi")
);

-- Таблица Визиты (связующая)
CREATE TABLE "Vizity"
(
  "ID_vizita"          Int            NOT NULL,
  "Data_vremya"        TIMESTAMP,
  "ID_klienta"         Int            NOT NULL,
  "ID_mastera"         Int            NOT NULL,
  "Obshchaya_stoimost" Decimal(10,2),
  "Kod_uslugi"         Int            NOT NULL,
  CONSTRAINT "PK_Vizity" PRIMARY KEY ("ID_vizita", "ID_klienta", "ID_mastera", "Kod_uslugi")
);

-- Внешние ключи
ALTER TABLE "Vizity"
  ADD CONSTRAINT "FK_Vizity_Klienty"
    FOREIGN KEY ("ID_klienta")
    REFERENCES "Klienty" ("ID_klienta")
      ON DELETE CASCADE
      ON UPDATE CASCADE;

ALTER TABLE "Vizity"
  ADD CONSTRAINT "FK_Vizity_Mastera"
    FOREIGN KEY ("ID_mastera")
    REFERENCES "Mastera" ("ID_mastera")
      ON DELETE CASCADE
      ON UPDATE CASCADE;

ALTER TABLE "Vizity"
  ADD CONSTRAINT "FK_Vizity_Uslugi"
    FOREIGN KEY ("Kod_uslugi")
    REFERENCES "Uslugi" ("Kod_uslugi")
      ON DELETE CASCADE
      ON UPDATE CASCADE;
