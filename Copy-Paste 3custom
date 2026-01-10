#Requires AutoHotkey v2.0

MyMenu := Menu()
MyMenu.Add("Copy Referensi (F7)", CopyReferensi)
MyMenu.Add("Copy Nama (F8)", CopyNama)
MyMenu.Add("Copy Alamat (F9)", CopyAlamat)
MyMenu.Add()
MyMenu.Add("Paste Referensi (F10)", PasteReferensi)
MyMenu.Add("Paste Nama (F11)", PasteNama)
MyMenu.Add("Paste Alamat (F12)", PasteAlamat)

~RButton:: {
    MouseGetPos(&xpos, &ypos)
    MyMenu.Show(xpos, ypos)
}

CopyReferensi(*) {
    Send("^c")
    global referensi := A_Clipboard
    Sleep(300)
    A_Clipboard := ""
}

CopyNama(*) {
    Send("^c")
    global nama := A_Clipboard
    Sleep(300)
    A_Clipboard := ""
}

CopyAlamat(*) {
    Send("^c")
    global alamat := A_Clipboard
    Sleep(300)
    A_Clipboard := ""
}

PasteReferensi(*) {
    if referensi != "" {
        A_Clipboard := referensi
        Sleep(100)
        Send("^v")
    }
}

PasteNama(*) {
    if nama != "" {
        A_Clipboard := nama
        Sleep(100)
        Send("^v")
    }
}

PasteAlamat(*) {
    if alamat != "" {
        A_Clipboard := alamat
        Sleep(100)
        Send("^v")
    }
}

F7::CopyReferensi()
F8::CopyNama()
F9::CopyAlamat()
F10::PasteReferensi()
F11::PasteNama()
F12::PasteAlamat()
