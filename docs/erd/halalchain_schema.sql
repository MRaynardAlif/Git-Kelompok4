-- =====================================================================
-- HalalChain - Skema basis data (MySQL 8 / MariaDB 10.5+)
-- Mengikuti ERD crow's foot: 7 entitas, semua PK buatan (surrogate)
-- =====================================================================

DROP DATABASE IF EXISTS halalchain;
CREATE DATABASE halalchain CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE halalchain;

-- ---------------------------------------------------------------------
-- 1. USAHA
-- ---------------------------------------------------------------------
CREATE TABLE usaha (
    id_usaha      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_usaha    VARCHAR(150) NOT NULL,
    nama_pemilik  VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL,
    kata_sandi    VARCHAR(255) NOT NULL,            -- simpan hash, bukan teks asli
    CONSTRAINT uq_usaha_email UNIQUE (email)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. PEMASOK  (USAHA 1:N PEMASOK, partisipasi anak total)
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
    status                    ENUM('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
    CONSTRAINT fk_pemasok_usaha
        FOREIGN KEY (id_pemasok, id_usaha) REFERENCES pemasok(id_pemasok, id_usaha)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_pemasok_usaha UNIQUE (id_pemasok, id_usaha),
    INDEX idx_pemasok_usaha (id_usaha)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. BAHAN_BAKU  (USAHA 1:N BAHAN_BAKU, PEMASOK 1:N BAHAN_BAKU)
--    Status halal TIDAK disimpan: diturunkan lewat view di bawah.
-- ---------------------------------------------------------------------
CREATE TABLE bahan_baku (
    id_bahan             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usaha             INT UNSIGNED NOT NULL,
    id_pemasok           INT UNSIGNED NOT NULL,
    nama_bahan           VARCHAR(150) NOT NULL,
    kategori             VARCHAR(80)  NOT NULL,
    asal_negara_produsen VARCHAR(100),
    no_sertifikat_halal  VARCHAR(80)  NULL,          -- NULL = belum ada sertifikat
    lembaga_penerbit     VARCHAR(100) NULL,
    masa_berlaku         DATE         NULL,
    foto_bahan           VARCHAR(255) NULL,          -- path / URL berkas
    dokumen_sertifikat   VARCHAR(255) NULL,
    catatan              TEXT,
    CONSTRAINT fk_bahan_usaha
        FOREIGN KEY (id_usaha) REFERENCES usaha(id_usaha)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bahan_pemasok
        FOREIGN KEY (id_pemasok) REFERENCES pemasok(id_pemasok)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- jika nomor sertifikat ada, masa berlaku wajib diisi
    CONSTRAINT ck_bahan_sertifikat
        CHECK (no_sertifikat_halal IS NULL OR masa_berlaku IS NOT NULL),
    INDEX idx_bahan_usaha (id_usaha),
    INDEX idx_bahan_pemasok (id_pemasok),
    INDEX idx_bahan_kategori (kategori)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. KRITERIA_SJH
-- ---------------------------------------------------------------------
CREATE TABLE kriteria_sjh (
    id_kriteria   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_kriteria VARCHAR(100) NOT NULL,
    CONSTRAINT uq_kriteria_nama UNIQUE (nama_kriteria)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. PERTANYAAN_SJH  (KRITERIA_SJH 1:N PERTANYAAN_SJH)
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
-- 6. JAWABAN_SJH  (tabel jembatan USAHA M:N PERTANYAAN_SJH)
-- ---------------------------------------------------------------------
CREATE TABLE jawaban_sjh (
    id_jawaban    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usaha      INT UNSIGNED NOT NULL,
    id_pertanyaan INT UNSIGNED NOT NULL,
    jawaban       ENUM('Ya','Sebagian','Tidak') NOT NULL,
    catatan_bukti TEXT,
    tanggal_isi   DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_jawaban_usaha
        FOREIGN KEY (id_usaha) REFERENCES usaha(id_usaha)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_jawaban_pertanyaan
        FOREIGN KEY (id_pertanyaan) REFERENCES pertanyaan_sjh(id_pertanyaan)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- satu usaha hanya punya satu jawaban aktif per pertanyaan
    CONSTRAINT uq_jawaban_usaha_pertanyaan UNIQUE (id_usaha, id_pertanyaan)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. LAPORAN_SJH  (USAHA 1:N LAPORAN_SJH)
--    Skor tidak disimpan: dihitung dari v_kesiapan_sjh saat laporan dicetak.
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
-- VIEW untuk atribut turunan (tidak disimpan di tabel)
-- =====================================================================

-- Status halal bahan: Halal / Belum Ada Sertifikat / Kedaluwarsa
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

-- Skor per kriteria: Ya = 1, Sebagian = 0.5, Tidak = 0
CREATE OR REPLACE VIEW v_skor_kriteria AS
SELECT u.id_usaha,
       k.id_kriteria,
       k.nama_kriteria,
       ROUND(100 * SUM(CASE j.jawaban
                           WHEN 'Ya'       THEN 1
                           WHEN 'Sebagian' THEN 0.5
                           ELSE 0 END) / COUNT(q.id_pertanyaan), 0) AS skor_persen
FROM usaha u
CROSS JOIN kriteria_sjh k
JOIN pertanyaan_sjh q ON q.id_kriteria = k.id_kriteria
LEFT JOIN jawaban_sjh j ON j.id_pertanyaan = q.id_pertanyaan
                       AND j.id_usaha      = u.id_usaha
GROUP BY u.id_usaha, k.id_kriteria, k.nama_kriteria;

-- Kesiapan SJH keseluruhan per usaha
CREATE OR REPLACE VIEW v_kesiapan_sjh AS
SELECT id_usaha, ROUND(AVG(skor_persen), 0) AS kesiapan_persen
FROM v_skor_kriteria
GROUP BY id_usaha;

-- Jumlah bahan per pemasok (kolom "Jml Bahan" di layar Pemasok)
CREATE OR REPLACE VIEW v_jumlah_bahan_pemasok AS
SELECT p.id_pemasok,
       p.id_usaha,
       p.nama_pemasok,
       COUNT(b.id_bahan) AS jml_bahan
FROM pemasok p
LEFT JOIN bahan_baku b ON b.id_pemasok = p.id_pemasok
GROUP BY p.id_pemasok, p.id_usaha, p.nama_pemasok;

-- =====================================================================
-- DATA AWAL: 11 kriteria SJH (sesuai layar Checklist)
-- =====================================================================
INSERT INTO kriteria_sjh (nama_kriteria) VALUES
 ('Kebijakan Halal'),
 ('Tim Manajemen Halal'),
 ('Pelatihan dan Edukasi'),
 ('Bahan'),
 ('Produk'),
 ('Fasilitas Produksi'),
 ('Prosedur Aktivitas Kritis'),
 ('Kemampuan Telusur'),
 ('Penanganan Produk Tidak Sesuai'),
 ('Audit Internal'),
 ('Kaji Ulang Manajemen');

-- Contoh pertanyaan (isi lengkap mengikuti standar BPJH/MUI)
INSERT INTO pertanyaan_sjh (id_kriteria, nomor_urut, teks_pertanyaan)
SELECT id_kriteria, 1, 'Contoh pertanyaan kriteria Bahan (ganti dengan teks standar BPJH/MUI).'
FROM kriteria_sjh WHERE nama_kriteria = 'Bahan';
