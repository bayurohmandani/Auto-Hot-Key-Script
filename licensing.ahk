#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; 0. SAKELAR ONLINE & SISTEM LISENSI
; ==============================================================================
VerifikasiLisensi(ManualCheck := false) {
    static URL  := "https://raw.githubusercontent.com/bayurohmandani/Auto-Hot-Key-Script/main/control.json"
    local TmpDir := EnvGet("TEMP") "\SemarAutomation"
    local TmpFile := TmpDir "\license_cache.json"
    local HariIni := FormatTime(, "yyyyMMdd")
   
    if !DirExist(TmpDir)
        DirCreate(TmpDir)

    ; Jika cek manual (Ctrl+L), kita paksa download ulang agar data fresh
    DownloadBaru := ManualCheck
    if !DownloadBaru && FileExist(TmpFile) {
        WaktuFile := FileGetTime(TmpFile, "M")
        if (SubStr(WaktuFile, 1, 8) != HariIni)
            DownloadBaru := true
    } else if !FileExist(TmpFile) {
        DownloadBaru := true
    }

    if (DownloadBaru) {
        try {
            Download(URL, TmpFile)
        } catch {
            if !FileExist(TmpFile) {
                MsgBox("Koneksi internet diperlukan untuk verifikasi.", "Offline", "Iconx")
                ExitApp()
            }
        }
    }

    try {
        Konten := FileRead(TmpFile)
       
        ; 1. Cek Status Enabled
        if !RegExMatch(Konten, '"enabled":\s*true') {
            MsgBox("Program tidak lagi dapat digunakan. `n Untuk menggunakan kembali, konfirmasi manajer/spv untuk menghubungi saya via dm IG @bayurohmand.", "Akses Ditolak", "Iconx")
            ExitApp()
        }

        ; 2. Cek Expiry & Hitung Sisa Hari
        if RegExMatch(Konten, '"expiry":\s*"([^"]+)"', &Match) {
            TglExp := Match[1]
            TglExpClean := StrReplace(TglExp, "-", "")
           
            ; Hitung selisih hari
            Selisih := DateDiff(TglExpClean, HariIni, "Days")

            if (Selisih < 0) {
                RegExMatch(Konten, '"message":\s*"([^"]+)"', &Msg)
                MsgBox(Msg ? Msg[1] : "Lisensi Expired! Untuk menggunakan kembali, konfirmasi manajer/spv untuk menghubungi saya via dm IG @bayurohmand.", "Expired", "Iconx")
                ExitApp()
            }

            ; Jika ditekan manual (Ctrl+L)
            if (ManualCheck) {
                MsgBox("Status Lisensi: AKTIF`n`n dm IG @bayurohmand untuk pemesanan otomatisasi lainnya `n`nKadaluarsa: " TglExp "`nSisa: " Selisih " hari lagi.", "Info Lisensi", "Iconi")
            }
        }
    } catch {
        MsgBox("Gagal membaca data lisensi.", "Error", "Iconx")
        if !ManualCheck
            ExitApp()
    }
}
^l:: VerifikasiLisensi(true)  ; Ctrl+L untuk cek lisensi manual
; Jalankan verifikasi otomatis saat script pertama kali dibuka
VerifikasiLisensi(false)

