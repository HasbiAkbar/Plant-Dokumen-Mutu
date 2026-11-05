# PLANT DOC PM
**Master Project Management – Penyusunan Dokumen Mutu Departemen Plant 2027**

Prototype awal aplikasi web untuk membantu monitoring pemetaan kebutuhan dokumen, register dokumen, penugasan penyusunan, dan progress pekerjaan.

## Menjalankan prototype
1. Buka folder repository ini di Antigravity atau File Explorer.
2. Buka file `index.html` menggunakan browser (Chrome/Edge).
3. Data yang dimasukkan pada prototype disimpan di browser lokal melalui localStorage.

## Modul prototype
- Dashboard ringkasan dokumen dan progress penugasan.
- Master Dokumen: kode, nama, jenis, elemen, status, dan PIC.
- Penugasan: PIC, prioritas, target, dan progress.
- Halaman Elemen Plant sebagai tempat pemetaan 14 elemen resmi.
- Halaman Tim & PIC sebagai placeholder untuk tahap pengembangan akses pengguna.

## Catatan penting
- Data elemen resmi dan gap dokumen belum dimasukkan. Sumber acuannya adalah file analisis `ELEMEN PLANT.xlsx` dari tim Plant; jangan mengisi nama elemen berdasarkan asumsi.
- Prototype ini belum memiliki database bersama, login Gmail, role-based access, sinkronisasi antar pengguna, atau hosting.
- Data localStorage hanya tersimpan pada browser/perangkat yang digunakan. Jangan gunakan data prototype ini sebagai master resmi sebelum backend dan autentikasi disiapkan.
- Google Docs/Drive akan digunakan sebagai lokasi drafting; aplikasi menyimpan metadata dan tautan, bukan mengunggah isi dokumen.

## Repository
Private repository: `HasbiAkbar/Plant-Dokumen-Mutu`
Default branch: `main`
