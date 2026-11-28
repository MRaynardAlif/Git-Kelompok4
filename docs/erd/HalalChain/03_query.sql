-- =====================================================================
-- HalalChain - Kumpulan Query Aplikasi (03_query.sql)
-- Diselaraskan dengan model: Checklist, Dashboard, Material,
-- Report, Supplier, dan User
-- =====================================================================
USE halalchain;

-- =====================================================================
-- QUERY 1 (JOIN 3 Tabel)
-- Pertanyaan bisnis: Apa saja detail jawaban checklist SJH beserta nama
--   kriteria, nomor urut, dan teks pertanyaannya untuk usaha tertentu?
-- Halaman atau fitur: Checklist SJH & Laporan SJH (Checklist::formDataByBusiness / ReportController::answersByBusiness)
-- Jumlah baris hasil: 12 baris (untuk id_usaha = 1 pada data seed; bervariasi sesuai jawaban usaha)
-- =====================================================================
SELECT k.id_kriteria,
       k.nama_kriteria,
       p.id_pertanyaan,
       p.nomor_urut,
       p.teks_pertanyaan,
       j.id_jawaban,
       j.jawaban,
       j.catatan_bukti,
       j.tanggal_isi
FROM kriteria_sjh k
LEFT JOIN pertanyaan_sjh p
       ON p.id_kriteria = k.id_kriteria
LEFT JOIN jawaban_sjh j
       ON j.id_pertanyaan = p.id_pertanyaan
      AND j.id_usaha = 1
ORDER BY k.id_kriteria ASC, p.nomor_urut ASC, p.id_pertanyaan ASC;

-- =====================================================================
-- QUERY 2 (LEFT JOIN dengan IS NULL)
-- Pertanyaan bisnis: Pertanyaan checklist SJH mana saja yang belum pernah
--   dijawab oleh usaha tertentu sehingga perlu dilengkapi?
-- Halaman atau fitur: Checklist SJH / Progres Pengisian (ChecklistController::index)
-- Jumlah baris hasil: 10 baris (untuk id_usaha = 1 dari 22 pertanyaan contoh; bervariasi sesuai progres usaha)
-- =====================================================================
SELECT p.id_pertanyaan,
       k.id_kriteria,
       k.nama_kriteria,
       p.nomor_urut,
       p.teks_pertanyaan
FROM pertanyaan_sjh p
INNER JOIN kriteria_sjh k
        ON k.id_kriteria = p.id_kriteria
LEFT JOIN jawaban_sjh j
       ON j.id_pertanyaan = p.id_pertanyaan
      AND j.id_usaha = 1
WHERE j.id_jawaban IS NULL
ORDER BY k.id_kriteria ASC, p.nomor_urut ASC;

-- =====================================================================
-- QUERY 3 (LEFT JOIN dengan IS NULL)
-- Pertanyaan bisnis: Pemasok mana milik usaha tertentu yang belum memiliki
--   bahan baku terdaftar sama sekali?
-- Halaman atau fitur: Manajemen Pemasok (Supplier::allByBusiness / SupplierController::destroy)
-- Jumlah baris hasil: 1 baris (untuk id_usaha = 1 pada data seed; bervariasi sesuai relasi pemasok-bahan)
-- =====================================================================
SELECT pm.id_pemasok,
       pm.nama_pemasok,
       pm.kota,
       pm.telepon,
       pm.status
FROM pemasok pm
LEFT JOIN bahan_baku b
       ON b.id_pemasok = pm.id_pemasok
      AND b.id_usaha = pm.id_usaha
WHERE pm.id_usaha = 1
  AND b.id_bahan IS NULL
ORDER BY pm.nama_pemasok ASC;

-- =====================================================================
-- QUERY 4 (GROUP BY dengan HAVING)
-- Pertanyaan bisnis: Kategori bahan baku mana saja yang memiliki minimal 2
--   bahan baku pada usaha tertentu?
-- Halaman atau fitur: Dashboard & Bahan Baku (DashboardController::index / MaterialController::index)
-- Jumlah baris hasil: 1 baris (untuk id_usaha = 1 pada data seed; bervariasi sesuai komposisi kategori)
-- =====================================================================
SELECT kategori,
       COUNT(*) AS jumlah_bahan
FROM bahan_baku
WHERE id_usaha = 1
GROUP BY kategori
HAVING COUNT(*) >= 2
ORDER BY jumlah_bahan DESC, kategori ASC;

-- =====================================================================
-- QUERY 5 (GROUP BY dengan HAVING)
-- Pertanyaan bisnis: Kriteria SJH mana saja pada usaha tertentu yang memiliki
--   rata-rata nilai jawaban (Ya=2, Sebagian=1, Tidak=0) di bawah 1.50?
-- Halaman atau fitur: Rekomendasi & Evaluasi Kesiapan SJH (ReportController::buildRecommendations / ChecklistController::index)
-- Jumlah baris hasil: 3 baris (untuk id_usaha = 1 pada data seed; bervariasi sesuai jawaban checklist)
-- =====================================================================
SELECT k.id_kriteria,
       k.nama_kriteria,
       COUNT(j.id_jawaban) AS jumlah_jawaban,
       ROUND(AVG(CASE j.jawaban
                     WHEN 'Ya'       THEN 2
                     WHEN 'Sebagian' THEN 1
                     ELSE 0
                 END), 2) AS rata_rata_nilai
FROM kriteria_sjh k
INNER JOIN pertanyaan_sjh p
        ON p.id_kriteria = k.id_kriteria
INNER JOIN jawaban_sjh j
        ON j.id_pertanyaan = p.id_pertanyaan
WHERE j.id_usaha = 1
GROUP BY k.id_kriteria, k.nama_kriteria
HAVING AVG(CASE j.jawaban
               WHEN 'Ya'       THEN 2
               WHEN 'Sebagian' THEN 1
               ELSE 0
           END) < 1.5
ORDER BY rata_rata_nilai ASC, k.id_kriteria ASC;

-- =====================================================================
-- QUERY 6 (Subquery)
-- Pertanyaan bisnis: Bahan baku mana milik usaha tertentu yang berasal dari
--   pemasok berstatus 'nonaktif'?
-- Halaman atau fitur: Manajemen Bahan Baku & Audit Pemasok (MaterialController::index / ReportController::sjhPdf)
-- Jumlah baris hasil: 1 baris (untuk id_usaha = 1 pada data seed; bervariasi sesuai status pemasok)
-- =====================================================================
SELECT id_bahan,
       id_pemasok,
       nama_bahan,
       kategori,
       no_sertifikat_halal,
       masa_berlaku
FROM bahan_baku
WHERE id_usaha = 1
  AND id_pemasok IN (
      SELECT id_pemasok
      FROM pemasok
      WHERE id_usaha = 1
        AND status = 'nonaktif'
  )
ORDER BY nama_bahan ASC;

-- =====================================================================
-- QUERY 7 (INSERT SELECT ... ON DUPLICATE KEY UPDATE)
-- Pertanyaan bisnis: Bagaimana cara menyimpan atau memperbarui jawaban
--   checklist SJH secara aman untuk pertanyaan yang terdaftar?
-- Halaman atau fitur: Simpan Checklist SJH (ChecklistController::store / Checklist::saveAnswers)
-- Jumlah baris hasil: 1 baris terpengaruh saat INSERT/UPDATE (0 baris jika id_pertanyaan tidak ditemukan)
-- =====================================================================
INSERT INTO jawaban_sjh (id_usaha, id_pertanyaan, jawaban, catatan_bukti, tanggal_isi)
SELECT 1, p.id_pertanyaan, 'Ya', 'Dokumen SOP prosedur kritis sudah tersedia', CURRENT_DATE
FROM pertanyaan_sjh p
WHERE p.id_pertanyaan = 1
ON DUPLICATE KEY UPDATE
    jawaban       = VALUES(jawaban),
    catatan_bukti = VALUES(catatan_bukti),
    tanggal_isi   = CURRENT_DATE;
