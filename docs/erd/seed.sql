-- =====================================================================
-- HalalChain - seed data
-- Import AFTER schema.sql, with the halalchain database selected.
-- Run this file only once on an empty database (criteria names are UNIQUE).
-- =====================================================================

-- 11 SJH criteria (as shown in the Checklist screen)
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

-- PLACEHOLDER questions: 2 per criterion, so the checklist screen and the
-- score views can be tested. These are NOT the official wording.
-- Before the real demo, replace them with the questions from the BPJH/MUI
-- standard (UPDATE the teks_pertanyaan, or delete these rows and insert
-- the real ones with the same id_kriteria / nomor_urut pattern).
INSERT INTO pertanyaan_sjh (id_kriteria, nomor_urut, teks_pertanyaan)
SELECT k.id_kriteria,
       n.nomor,
       CONCAT('[CONTOH] Pertanyaan ', n.nomor, ' kriteria ', k.nama_kriteria,
              ' (ganti dengan teks standar BPJH/MUI).')
FROM kriteria_sjh k
CROSS JOIN (SELECT 1 AS nomor UNION ALL SELECT 2) n;
