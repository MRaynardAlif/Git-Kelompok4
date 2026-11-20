-- HalalChain - seed data
-- Import AFTER schema.sql, with the halalchain database selected.
-- Run only once on an empty database (criteria names are UNIQUE).

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

-- PLACEHOLDER questions (2 per criterion). Replace with the BPJH/MUI wording.
INSERT INTO pertanyaan_sjh (id_kriteria, nomor_urut, teks_pertanyaan)
SELECT k.id_kriteria,
       n.nomor,
       CONCAT('[CONTOH] Pertanyaan ', n.nomor, ' kriteria ', k.nama_kriteria,
              ' (ganti dengan teks standar BPJH/MUI).')
FROM kriteria_sjh k
CROSS JOIN (SELECT 1 AS nomor UNION ALL SELECT 2) n;
