#Requires AutoHotkey v2.0
#SingleInstance Force

; Jalankan sebagai Admin agar tembus ke aplikasi ERP
if not A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; Inisialisasi InputHook
ih := InputHook("V")
ih.OnChar := CheckSequence
ih.Start()

global global_buffer := ""

; --- RESET LOGIC ---
; Reset buffer setiap kali klik kiri (pindah kolom atau klik tombol Save/New)
~LButton::ResetBuffer()

; Reset buffer jika menekan Enter (setelah scan barcode atau submit)
~Enter::ResetBuffer()

; Reset buffer jika menekan Esc (batal)
~Tab::ResetBuffer()
~Esc::ResetBuffer()
F5::Reload()
ResetBuffer() {
    global global_buffer
    ih.Start()
    global_buffer := ""
}

; --- DETEKSI KETIKAN ---
CheckSequence(ih, char) {
    global global_buffer
    global_buffer .= char
    
    ; Batasi buffer hanya 3 karakter terakhir
    if StrLen(global_buffer) > 3
        global_buffer := SubStr(global_buffer, -3)

    ; Cek perintah
    if (global_buffer = "0.1")
        inputCommand("Tambahan")
    else if (global_buffer = "0.2")
        inputCommand("Duotambahan")
    else if (global_buffer = "0.3")
        inputCommand("Tretambahan")
    else if (global_buffer = "0.4")
        inputCommand("Batangan")
}

; --- EKSEKUSI INPUT ---
inputCommand(warehouse) {
    ih.Stop()
    global global_buffer
    ;ih.Stop() ; Berhenti mendengarkan agar ketikan script tidak masuk buffer
    
    ; Hapus pemicu "0.1"
    SendEvent("{BackSpace 3}")
    Sleep(50)
    
    ; Atur kecepatan ketik (Sesuaikan 40ms jika ERP Anda lambat)
   ; SetKeyDelay(10, 10)
    
    ; Isi Branch
    SendEvent("Online")
    Sleep(200) ; Jeda agar dropdown ERP muncul
    Send("{Tab}")
    
    ; Isi Warehouse
    Sleep(200)
    SendEvent(warehouse)
    Sleep(200)
    Send("{Tab}")
    
    ; Selesai, kosongkan buffer dan mulai rekam lagi
    ;global_buffer := ""
    ih.Start()
}
