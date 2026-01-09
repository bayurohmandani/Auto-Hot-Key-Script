#Requires AutoHotkey v2.0
#SingleInstance Force

; ===============================
; KONFIGURASI
; ===============================
LICENSE_URL := "https://raw.githubusercontent.com/bayurohmandani/Auto-Hot-Key-Script/main/control.json"
CACHE_DIR   := A_AppData "\MyApp"
CACHE_FILE  := CACHE_DIR "\license.dat" ; Ganti ekstensi agar tidak mencurigakan
CHECK_INTERVAL := 86400

if !DirExist(CACHE_DIR)
    DirCreate(CACHE_DIR)

; ===============================
; STARTUP CHECK
; ===============================
if !IsCacheValid(CACHE_FILE, CHECK_INTERVAL) {
    try {
        ; Download ke memori dulu, lalu encode sebelum simpan
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", LICENSE_URL, false)
        whr.Send()
        
        if (whr.Status == 200) {
            rawJson := whr.ResponseText
            ; Simpan dalam bentuk Base64
            FileOpen(CACHE_FILE, "w").Write(Base64Encode(rawJson))
        }
    } catch {
        if !FileExist(CACHE_FILE) {
            MsgBox("Gagal memverifikasi lisensi. Koneksi internet diperlukan.", "Error")
            ExitApp()
        }
    }
}

; Baca dan Decode
try {
    encodedData := FileRead(CACHE_FILE)
    decodedJson := Base64Decode(encodedData)
    
    if !IsLicenseAllowed(decodedJson)
        ExitApp()
} catch {
    MsgBox("File lisensi rusak.")
    ExitApp()
}

MsgBox("Aplikasi Berhasil Dijalankan!", "Sukses", "Iconi")

; ===============================
; FUNCTIONS
; ===============================

IsLicenseAllowed(jsonContent) {
    if InStr(jsonContent, '"enabled": false') {
        ShowMessage(jsonContent)
        return false
    }

    if RegExMatch(jsonContent, '"expiry":\s*"([\d-]+)"', &m) {
        if (FormatTime(, "yyyy-MM-dd") > m[1]) {
            ShowMessage(jsonContent)
            return false
        }
    }
    return true
}

ShowMessage(json) {
    msg := RegExMatch(json, '"message":\s*"(.+?)"', &m) ? m[1] : "Akses ditolak."
    MsgBox(msg, "Lisensi")
}

IsCacheValid(filePath, maxAge) {
    if !FileExist(filePath)
        return false
    return DateDiff(A_NowUTC, FileGetTime(filePath, "M"), "Seconds") < maxAge
}

Base64Encode(string) {
    static code := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    sLen := StrPut(string, "UTF-8")
    buf := Buffer(sLen)
    StrPut(string, buf, "UTF-8")
    
    out := ""
    i := 0
    while (i < sLen - 1) {
        v := (NumGet(buf, i, "UChar") << 16) | (NumGet(buf, i+1, "UChar") << 8) | NumGet(buf, i+2, "UChar")
        out .= SubStr(code, ((v >> 18) & 63) + 1, 1)
            .  SubStr(code, ((v >> 12) & 63) + 1, 1)
            .  SubStr(code, ((v >> 6) & 63) + 1, 1)
            .  SubStr(code, (v & 63) + 1, 1)
        i += 3
    }
    return out
}

Base64Decode(s) {
    static code := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    ; Decoding sederhana untuk keperluan proteksi file lokal
    ; Menggunakan Windows Crypt32 untuk hasil yang lebih solid
    size := StrLen(RTrim(s, "=")) * 3 // 4
    bin := Buffer(size)
    DllCall("crypt32\CryptStringToBinary", "Str", s, "UInt", 0, "UInt", 1, "Ptr", bin, "UInt*", &size, "Ptr", 0, "Ptr", 0)
    return StrGet(bin, size, "UTF-8")
}
