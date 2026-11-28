-- =====================================================================
-- HalalChain - Data Contoh (Dummy Data)
-- Jalankan SETELAH 01_skema.sql dan seed_dummyPertanyaan.sql
-- =====================================================================
USE halalchain;

-- ---------------------------------------------------------------------
-- 1. USAHA (5 baris; password contoh = 'password123')
-- ---------------------------------------------------------------------
INSERT INTO usaha (id_usaha, nama_usaha, nama_pemilik, email, kata_sandi) VALUES
(1, 'Dapur Nusantara Berkah', 'Budi Santoso', 'test1@dapurnusantara.id', '$2y$12$xoWzZJAYC7gyUrFyzfpkmebEm4RjU33i/uDE/0f..4SdwLTON.78K'),
(2, 'Kopi Senja & Roti', 'Siti Aminah', 'test2@kopisenja.id', '$2y$12$dKNZArnUcbrOwBAgKtEYN.4e5I6OaZglyONBDXOrdNxePv1pqOCrK'),
(3, 'Warung Mie Jogja Asli', 'Hendra Wijaya', 'test3@miejogja.id', '$2y$12$oeS/Cx.Avo1K3OnlBYbus.Xqut/5J2Sn2hB2cNjkV0nJEK3EQwPH2'),
(4, 'Bakery Manis Rasa', 'Dewi Lestari', 'test4@manisrasa.id', '$2y$12$k/DQ7I2slcZM9M4ddND9HeFtKUCSA3QqIEtu3g8AwJ2.msjRGjckW'),
(5, 'Sate Klathak Pak Rahmat', 'Rahmat Hidayat', 'test5@sateklathak.id', '$2y$12$19FV8ePeegHXfqvSZIztp.G1nfDRz6UFjajt7IL2NL1XI0CItbTH.');

-- Passwords tanpa hash untuk Login:
-- 1. DapurNusantara001
-- 2. KopiSenja002
-- 3. MieJogja003
-- 4. ManisRasa004
-- 5. SateKlathak005

-- ---------------------------------------------------------------------
-- 2. PEMASOK (6 baris; id_pemasok=7 sengaja belum memiliki bahan_baku)
-- ---------------------------------------------------------------------
INSERT INTO pemasok (id_pemasok, id_usaha, nama_pemasok, alamat, kota, telepon, email, catatan_sertifikasi_halal, status) VALUES
(1, 1, 'PT Bogasari Flour Mills', 'Jl. Raya Cilincing No. 1', 'Jakarta Utara', '021-43900170', 'cs@bogasari.com', 'Sertifikat halal BPJPH aktif', 'aktif'),
(2, 1, 'CV Sumber Daging Segar', 'Jl. Magelang KM 8', 'Sleman', '0274-868123', 'order@sumberdaging.co.id', 'RPH bersertifikat halal BPJPH', 'aktif'),
(3, 1, 'UD Rempah Tradisional', 'Pasar Beringharjo Lt. 2', 'Yogyakarta', '081227001122', NULL, 'Bahan nabati murni (positive list)', 'aktif'),
(4, 1, 'PT Aneka Bumbu Lama', 'Jl. Solo KM 10', 'Sleman', '0274-496000', 'sales@anekabumbu.id', 'Proses perpanjangan sertifikat halal', 'nonaktif'),
(5, 2, 'PT Greenfields Indonesia', 'Jl. Raya Gunung Kawi', 'Malang', '0341-395222', 'info@greenfieldsdairy.com', 'Sertifikat halal BPJPH aktif', 'aktif'),
(7, 1, 'CV Kemasan Amanah', 'Jl. Gejayan No. 45', 'Depok', '0274-550112', NULL, 'Pemasok baru, belum ada bahan terdaftar', 'aktif');

-- ---------------------------------------------------------------------
-- 3. BAHAN_BAKU (7 baris; ada kolom nullable yang sengaja NULL)
-- ---------------------------------------------------------------------
INSERT INTO bahan_baku (id_bahan, id_usaha, id_pemasok, nama_bahan, kategori, asal_negara_produsen, no_sertifikat_halal, lembaga_penerbit, masa_berlaku, foto_bahan, dokumen_sertifikat, catatan) VALUES
(1, 1, 1, 'Tepung Terigu Segitiga Biru', 'Tepung & Biji-bijian', 'Indonesia', 'ID00410000012340521', 'BPJPH', '2028-05-20', 'uploads/bahan/terigu.jpg', 'uploads/sertifikat/sert_terigu.pdf', 'Bahan utama adonan'),
(2, 1, 2, 'Daging Sapi Has Dalam', 'Daging & Unggas', 'Indonesia', 'ID34110000456780922', 'BPJPH', '2027-09-15', 'uploads/bahan/daging_sapi.jpg', 'uploads/sertifikat/sert_daging.pdf', 'Disimpan di freezer terpisah'),
(3, 1, 4, 'Saus Tiram Spesial', 'Bumbu & Saus', 'Indonesia', '00060098765432', 'LPPOM MUI', '2025-12-31', 'uploads/bahan/saus_tiram.jpg', NULL, 'Sertifikat melewati masa berlaku'),
(4, 1, 3, 'Kunyit Bubuk Murni', 'Rempah', 'Indonesia', NULL, NULL, NULL, 'uploads/bahan/kunyit.jpg', NULL, 'Bahan tidak kritis (positive list)'),
(5, 1, 3, 'Kecap Manis Kedelai Hitam', 'Bumbu & Saus', 'Indonesia', NULL, NULL, NULL, NULL, NULL, 'Menunggu nomor sertifikat'),
(6, 2, 5, 'Susu UHT Full Cream 1L', 'Produk Olahan Susu', 'Indonesia', 'ID00410000099880123', 'BPJPH', '2028-01-10', 'uploads/bahan/susu_uht.jpg', 'uploads/sertifikat/sert_susu.pdf', 'Untuk kopi susu dan roti'),
(7, 2, 5, 'Mentega Tawar Kemasan', 'Produk Olahan Susu', 'Selandia Baru', NULL, NULL, NULL, NULL, NULL, 'Belum ada dokumen sertifikat');

-- ---------------------------------------------------------------------
-- 4. JAWABAN_SJH (12 baris; pertanyaan 13-22 & usaha 3-5 tanpa pasangan)
-- ---------------------------------------------------------------------
INSERT INTO jawaban_sjh (id_usaha, id_pertanyaan, jawaban, catatan_bukti, tanggal_isi) VALUES
(1, 1,  'Ya',       'SK Kebijakan Halal No. 01/DNB/2026', '2026-11-10'),
(1, 2,  'Ya',       'Poster kebijakan di area dapur', '2026-11-10'),
(1, 3,  'Ya',       'Surat penunjukan Penyelia Halal', '2026-11-11'),
(1, 4,  'Sebagian', 'Uraian tugas belum merata ke semua shift', '2026-11-11'),
(1, 5,  'Ya',       'Sertifikat pelatihan internal tersedia', '2026-11-12'),
(1, 6,  'Tidak',    'Belum ada jadwal pelatihan ulang rutin', '2026-11-12'),
(1, 7,  'Sebagian', 'Saus tiram perlu pembaruan sertifikat', '2026-11-15'),
(1, 8,  'Ya',       'Daftar bahan diperbarui berkala', '2026-11-15'),
(1, 9,  'Ya',       'Nama produk sesuai ketentuan', '2026-11-16'),
(1, 10, 'Ya',       'Komposisi bahan tercatat lengkap', '2026-11-16'),
(1, 11, 'Ya',       'Fasilitas bebas bahan nonhalal', '2026-11-18'),
(1, 12, 'Sebagian', 'Logbook pembersihan belum harian', '2026-11-18');

-- ---------------------------------------------------------------------
-- 5. LAPORAN_SJH (5 baris; beberapa file_pdf sengaja NULL)
-- ---------------------------------------------------------------------
INSERT INTO laporan_sjh (id_usaha, tanggal_laporan, sertakan_identitas, sertakan_skor, sertakan_rekomendasi, sertakan_daftar_bahan, rekomendasi_perbaikan, file_pdf) VALUES
(1, '2026-11-15', TRUE,  TRUE,  FALSE, FALSE, NULL, 'uploads/laporan/lap_dnb_20261115.pdf'),
(1, '2026-11-20', TRUE,  TRUE,  TRUE,  TRUE,  'Perbarui sertifikat saus tiram dan lengkapi jadwal pelatihan.', 'uploads/laporan/lap_dnb_20261120.pdf'),
(2, '2026-11-18', TRUE,  TRUE,  TRUE,  FALSE, 'Lengkapi sertifikat halal mentega tawar dan isi checklist SJH.', NULL),
(3, '2026-11-19', TRUE,  FALSE, FALSE, FALSE, NULL, NULL),
(4, '2026-11-21', TRUE,  TRUE,  TRUE,  TRUE,  'Mulai pengisian checklist seluruh kriteria SJH.', 'uploads/laporan/lap_manisrasa_20261121.pdf');
