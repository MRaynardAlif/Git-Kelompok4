-- =====================================================================
-- HalalChain - Skema Basis Data (MySQL 8.0+ / MariaDB 10.5+)
-- Urutan tabel: Induk ke Anak
-- =====================================================================

DROP DATABASE IF EXISTS halalchain;
CREATE DATABASE halalchain CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE halalchain;

-- ---------------------------------------------------------------------
-- 1. USAHA (Tabel Induk Utama)
-- ---------------------------------------------------------------------
CREATE TABLE usaha (
    id_usaha      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_usaha    VARCHAR(150) NOT NULL,
    nama_pemilik  VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL,
    kata_sandi    VARCHAR(255) NOT NULL,
    CONSTRAINT uq_usaha_email UNIQUE (email)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. KRITERIA_SJH (Tabel Induk Master Standar SJH)
-- ---------------------------------------------------------------------
CREATE TABLE kriteria_sjh (
    id_kriteria   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_kriteria VARCHAR(100) NOT NULL,
    CONSTRAINT uq_kriteria_nama UNIQUE (nama_kriteria)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. PERTANYAAN_SJH (Anak dari KRITERIA_SJH, Induk bagi JAWABAN_SJH)
-- ---------------------------------------------------------------------
CREATE TABLE pertanyaan_sjh (
    id_pertanyaan   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_kriteria     INT UNSIGNED NOT NULL,
    nomor_urut      SMALLINT UNSIGNED NOT NULL,
    teks_pertanyaan TEXT NOT NULL,
    CONSTRAINT fk_pertanyaan_kriteria
        FOREIGN KEY (id_kriteria) REFERENCES kriteria_sjh(id_kriteria)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_pertanyaan_urut UNIQUE (id_kriteria, nomor_urut)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. PEMASOK (Anak dari USAHA, Induk bagi BAHAN_BAKU)
-- ---------------------------------------------------------------------
CREATE TABLE pemasok (
    id_pemasok                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usaha                  INT UNSIGNED NOT NULL,
    nama_pemasok              VARCHAR(150) NOT NULL,
    alamat                    VARCHAR(255),
    kota                      VARCHAR(80),
    telepon                   VARCHAR(20),
    email                     VARCHAR(120),
    catatan_sertifikasi_halal TEXT,
    status                    VARCHAR(20) NOT NULL DEFAULT 'aktif',
    CONSTRAINT fk_pemasok_usaha
        FOREIGN KEY (id_usaha) REFERENCES usaha(id_usaha)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pemasok_status
        CHECK (status IN ('aktif', 'nonaktif')),
    CONSTRAINT uq_pemasok_usaha UNIQUE (id_pemasok, id_usaha),
    INDEX idx_pemasok_usaha (id_usaha)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. BAHAN_BAKU (Anak dari USAHA dan PEMASOK)
-- ---------------------------------------------------------------------
CREATE TABLE bahan_baku (
    id_bahan             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usaha             INT UNSIGNED NOT NULL,
    id_pemasok           INT UNSIGNED NOT NULL,
    nama_bahan           VARCHAR(150) NOT NULL,
    kategori             VARCHAR(80)  NOT NULL,
    asal_negara_produsen VARCHAR(100),
    no_sertifikat_halal  VARCHAR(80)  NULL,
    lembaga_penerbit     VARCHAR(100) NULL,
    masa_berlaku         DATE         NULL,
    foto_bahan           VARCHAR(255) NULL,
    dokumen_sertifikat   VARCHAR(255) NULL,
    catatan              TEXT,
    CONSTRAINT fk_bahan_usaha
        FOREIGN KEY (id_usaha) REFERENCES usaha(id_usaha)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bahan_pemasok
        FOREIGN KEY (id_pemasok) REFERENCES pemasok(id_pemasok)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_bahan_sertifikat
        CHECK (no_sertifikat_halal IS NULL OR masa_berlaku IS NOT NULL),
    INDEX idx_bahan_usaha (id_usaha),
    INDEX idx_bahan_pemasok (id_pemasok),
    INDEX idx_bahan_kategori (kategori)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. JAWABAN_SJH (Anak dari USAHA dan PERTANYAAN_SJH)
-- ---------------------------------------------------------------------
CREATE TABLE jawaban_sjh (
    id_jawaban    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usaha      INT UNSIGNED NOT NULL,
    id_pertanyaan INT UNSIGNED NOT NULL,
    jawaban       VARCHAR(20) NOT NULL,
    catatan_bukti TEXT,
    tanggal_isi   DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_jawaban_usaha
        FOREIGN KEY (id_usaha) REFERENCES usaha(id_usaha)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_jawaban_pertanyaan
        FOREIGN KEY (id_pertanyaan) REFERENCES pertanyaan_sjh(id_pertanyaan)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_jawaban_nilai
        CHECK (jawaban IN ('Ya', 'Sebagian', 'Tidak')),
    CONSTRAINT uq_jawaban_usaha_pertanyaan UNIQUE (id_usaha, id_pertanyaan)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. LAPORAN_SJH (Anak dari USAHA)
-- ---------------------------------------------------------------------
CREATE TABLE laporan_sjh (
    id_laporan            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usaha              INT UNSIGNED NOT NULL,
    tanggal_laporan       DATE NOT NULL DEFAULT (CURRENT_DATE),
    sertakan_identitas    BOOLEAN NOT NULL DEFAULT TRUE,
    sertakan_skor         BOOLEAN NOT NULL DEFAULT TRUE,
    sertakan_rekomendasi  BOOLEAN NOT NULL DEFAULT TRUE,
    sertakan_daftar_bahan BOOLEAN NOT NULL DEFAULT FALSE,
    rekomendasi_perbaikan TEXT,
    file_pdf              VARCHAR(255),
    CONSTRAINT fk_laporan_usaha
        FOREIGN KEY (id_usaha) REFERENCES usaha(id_usaha)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- VIEW ATRIBUT TURUNAN
-- =====================================================================

CREATE OR REPLACE VIEW v_status_bahan AS
SELECT b.id_bahan,
       b.id_usaha,
       b.id_pemasok,
       b.nama_bahan,
       b.kategori,
       p.nama_pemasok,
       b.no_sertifikat_halal,
       b.foto_bahan,
       b.masa_berlaku,
       CASE
           WHEN b.no_sertifikat_halal IS NULL THEN 'Belum Ada Sertifikat'
           WHEN b.masa_berlaku < CURRENT_DATE THEN 'Kedaluwarsa'
           ELSE 'Halal'
       END AS status_halal
FROM bahan_baku b
JOIN pemasok p ON p.id_pemasok = b.id_pemasok;

CREATE OR REPLACE VIEW v_skor_kriteria AS
SELECT u.id_usaha,
       k.id_kriteria,
       k.nama_kriteria,
       ROUND(100 * SUM(CASE j.jawaban
                           WHEN 'Ya'       THEN 1
                           WHEN 'Sebagian' THEN 0.5
                           ELSE 0 END) / NULLIF(COUNT(q.id_pertanyaan), 0), 0) AS skor_persen
FROM usaha u
CROSS JOIN kriteria_sjh k
LEFT JOIN pertanyaan_sjh q ON q.id_kriteria = k.id_kriteria
LEFT JOIN jawaban_sjh j ON j.id_pertanyaan = q.id_pertanyaan
                       AND j.id_usaha      = u.id_usaha
GROUP BY u.id_usaha, k.id_kriteria, k.nama_kriteria;

CREATE OR REPLACE VIEW v_kesiapan_sjh AS
SELECT id_usaha, ROUND(AVG(COALESCE(skor_persen, 0)), 0) AS kesiapan_persen
FROM v_skor_kriteria
GROUP BY id_usaha;

CREATE OR REPLACE VIEW v_jumlah_bahan_pemasok AS
SELECT p.id_pemasok,
       p.id_usaha,
       p.nama_pemasok,
       COUNT(b.id_bahan) AS jml_bahan
FROM pemasok p
LEFT JOIN bahan_baku b ON b.id_pemasok = p.id_pemasok
GROUP BY p.id_pemasok, p.id_usaha, p.nama_pemasok;
