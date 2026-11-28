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

INSERT INTO pertanyaan_sjh (id_kriteria, nomor_urut, teks_pertanyaan)
SELECT k.id_kriteria, v.nomor, v.teks
FROM (
  SELECT 'Kebijakan Halal' AS nama, 1 AS nomor, '[Contoh] Apakah usaha Anda memiliki kebijakan halal tertulis yang ditandatangani pimpinan?' AS teks
  UNION ALL SELECT 'Kebijakan Halal', 2, '[Contoh] Apakah kebijakan halal sudah disosialisasikan kepada seluruh karyawan?'
  UNION ALL SELECT 'Tim Manajemen Halal', 1, '[Contoh] Apakah sudah ada tim atau penanggung jawab halal yang ditunjuk secara resmi?'
  UNION ALL SELECT 'Tim Manajemen Halal', 2, '[Contoh] Apakah tugas dan tanggung jawab tim halal sudah dituliskan dengan jelas?'
  UNION ALL SELECT 'Pelatihan dan Edukasi', 1, '[Contoh] Apakah karyawan yang terlibat produksi pernah mengikuti pelatihan tentang produk halal?'
  UNION ALL SELECT 'Pelatihan dan Edukasi', 2, '[Contoh] Apakah ada jadwal pelatihan ulang dan catatan kehadiran peserta?'
  UNION ALL SELECT 'Bahan', 1, '[Contoh] Apakah semua bahan baku yang digunakan memiliki sertifikat halal atau termasuk bahan yang tidak kritis?'
  UNION ALL SELECT 'Bahan', 2, '[Contoh] Apakah ada daftar bahan baku yang selalu diperbarui setiap ada perubahan bahan atau pemasok?'
  UNION ALL SELECT 'Produk', 1, '[Contoh] Apakah nama dan komposisi produk tidak mengandung unsur yang dilarang dalam syariat?'
  UNION ALL SELECT 'Produk', 2, '[Contoh] Apakah ada daftar produk lengkap beserta komposisi bahan di dalamnya?'
  UNION ALL SELECT 'Fasilitas Produksi', 1, '[Contoh] Apakah tempat dan peralatan produksi bebas dari najis dan bahan nonhalal?'
  UNION ALL SELECT 'Fasilitas Produksi', 2, '[Contoh] Apakah fasilitas produksi dibersihkan secara rutin sesuai jadwal yang dicatat?'
  UNION ALL SELECT 'Prosedur Aktivitas Kritis', 1, '[Contoh] Apakah ada prosedur tertulis untuk pembelian, produksi, dan penyimpanan bahan serta produk?'
  UNION ALL SELECT 'Prosedur Aktivitas Kritis', 2, '[Contoh] Apakah pelaksanaan prosedur tersebut dicatat dan mudah dicek kembali?'
  UNION ALL SELECT 'Kemampuan Telusur', 1, '[Contoh] Apakah setiap bahan baku dapat ditelusuri sampai ke pemasok dan sertifikat halalnya?'
  UNION ALL SELECT 'Kemampuan Telusur', 2, '[Contoh] Apakah produk jadi dapat ditelusuri ke bahan dan waktu produksinya?'
  UNION ALL SELECT 'Penanganan Produk Tidak Sesuai', 1, '[Contoh] Apakah ada prosedur untuk menangani bahan atau produk yang tidak memenuhi ketentuan halal?'
  UNION ALL SELECT 'Penanganan Produk Tidak Sesuai', 2, '[Contoh] Apakah produk yang tidak sesuai dipastikan tidak dijual dan kejadiannya dicatat?'
  UNION ALL SELECT 'Audit Internal', 1, '[Contoh] Apakah audit internal penerapan sistem jaminan halal dilakukan secara berkala?'
  UNION ALL SELECT 'Audit Internal', 2, '[Contoh] Apakah temuan audit internal ditindaklanjuti dan hasilnya didokumentasikan?'
  UNION ALL SELECT 'Kaji Ulang Manajemen', 1, '[Contoh] Apakah pimpinan secara berkala mengkaji ulang penerapan sistem jaminan halal?'
  UNION ALL SELECT 'Kaji Ulang Manajemen', 2, '[Contoh] Apakah hasil kaji ulang dicatat dan menghasilkan keputusan perbaikan?'
) v
JOIN kriteria_sjh k ON k.nama_kriteria = v.nama;
