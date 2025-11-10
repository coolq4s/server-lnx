import tkinter as tk
from tkinter import messagebox, simpledialog
import subprocess
import os
import sys
import json

polling_job = None # Global variable to hold the polling job ID
SAVED_NETWORKS_FILE = "saved_networks.json"
SUDO_PASSWORD = None # Global variable to store the sudo password

# --- Logika Baru: Memastikan skrip berjalan sebagai root di Linux/macOS ---
def run_as_root():
    """
    Memeriksa apakah skrip memiliki hak akses root atau meminta kata sandi sudo.
    """
    global SUDO_PASSWORD
    if sys.platform != "win32":
        # os.geteuid() hanya ada di sistem mirip Unix
        if os.geteuid() != 0:
            # Cek apakah sudo bisa berjalan tanpa password (sesi aktif)
            check_sudo_cmd = ['sudo', '-n', 'true']
            try:
                # Jika perintah ini berhasil, berarti password tidak diperlukan
                subprocess.run(check_sudo_cmd, check=True, stderr=subprocess.DEVNULL)
                SUDO_PASSWORD = "" # Tandai bahwa kita punya hak sudo tanpa perlu password
            except (subprocess.CalledProcessError, FileNotFoundError):
                # Jika gagal, berarti password diperlukan. Minta ke user.
                password = simpledialog.askstring("Hak Akses Root Diperlukan", 
                                                  "Masukkan kata sandi sudo Anda:", 
                                                  show='*')
                if not password:
                    messagebox.showerror("Gagal", "Kata sandi sudo diperlukan untuk menjalankan aplikasi ini.")
                    sys.exit(1)
                
                # Verifikasi kata sandi sudo yang dimasukkan
                verify_cmd = ['sudo', '-S', 'true']
                proc = subprocess.run(verify_cmd, input=password, text=True, capture_output=True)
                
                if proc.returncode != 0:
                    messagebox.showerror("Gagal", "Kata sandi sudo salah.")
                    sys.exit(1)
                SUDO_PASSWORD = password

def find_command(cmd):
    """Memeriksa apakah sebuah perintah ada di PATH sistem."""
    from shutil import which
    return which(cmd) is not None

def get_cli_command(args):
    """Membuat perintah dengan sudo jika diperlukan."""
    if sys.platform == "win32":
        return ["zerotier-cli"] + args
    else:
        if SUDO_PASSWORD is not None and SUDO_PASSWORD != "":
            return ['sudo', '-S'] + ["zerotier-cli"] + args
        elif SUDO_PASSWORD is not None: # Sesi sudo aktif, tidak perlu -S
            return ['sudo'] + ["zerotier-cli"] + args
        else: # Sudah berjalan sebagai root
            return ["zerotier-cli"] + args

def update_output(text):
    """Membersihkan dan menulis teks baru ke area output."""
    output_text.config(state=tk.NORMAL)
    output_text.delete("1.0", tk.END)
    output_text.insert(tk.END, text)
    output_text.config(state=tk.DISABLED)

def join_network():
    """
    Mengambil Network ID dari input dan menjalankan perintah 'zerotier-cli join'.
    """
    network_id = entry_network_id.get()
    if not network_id:
        messagebox.showwarning("Input Kosong", "Silakan masukkan Network ID.")
        return
    
    # Membersihkan output area dan menampilkan pesan 'mencoba bergabung'
    # setelah memastikan network_id tidak kosong.
    update_output(f"Mencoba bergabung dengan jaringan {network_id}...")

    # --- Logika Baru: Periksa dan tinggalkan jaringan aktif ---
    try:
        list_command = get_cli_command(["listnetworks", "-j"])
        list_result = subprocess.run(list_command, input=SUDO_PASSWORD, capture_output=True, text=True, check=True)
        current_networks = json.loads(list_result.stdout)
        
        active_network = next((net for net in current_networks if net.get("status") != "PRIVATE"), None)

        if active_network and active_network.get("nwid") != network_id:
            active_nwid = active_network.get("nwid")
            update_output(f"Jaringan aktif {active_nwid} ditemukan.\nMencoba keluar terlebih dahulu...")
            
            leave_command = get_cli_command(["leave", active_nwid])
            subprocess.run(leave_command, input=SUDO_PASSWORD, capture_output=True, text=True, check=True)
            
            update_output(f"Berhasil keluar dari {active_nwid}.\nSekarang mencoba bergabung dengan {network_id}...")
            app.update_idletasks() # Paksa GUI untuk update tampilan
            app.after(1000) # Beri jeda sesaat
    except (FileNotFoundError, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        print(f"Peringatan: Gagal memeriksa/meninggalkan jaringan lama. Melanjutkan proses join. Error: {e}")
    # --- Akhir Logika Baru ---

    try:
        # Perintah join
        command = get_cli_command(["join", network_id])
        result = subprocess.run(
            command,
            input=SUDO_PASSWORD,
            capture_output=True,
            text=True,
            check=True
        )
        # Output dari 'join' biasanya "200 join OK"
        if "200 join OK" in result.stdout:
            # Setelah berhasil, mulai periksa status koneksi secara berkala
            check_connection_status(network_id_to_watch=network_id)
        
    except FileNotFoundError:
        messagebox.showerror("Error", "Perintah 'zerotier-cli' not found.\nPastikan ZeroTier sudah terpasang dan path-nya benar.")
    except subprocess.CalledProcessError as e:
        # Menampilkan pesan error jika perintah gagal
        error_message = e.stderr
        output_text.config(state=tk.NORMAL)
        if "404" in error_message or "not found" in error_message:
            update_output(f"Gagal: Network ID '{network_id}' tidak ditemukan atau salah.\n")
        elif "join: already joined" in error_message:
            update_output(f"Informasi: Anda sudah tergabung dalam jaringan {network_id}.\n")
            check_connection_status(network_id_to_watch=network_id) # Perbarui GUI ke status 'terhubung'
        else:
            update_output(f"Gagal bergabung dengan jaringan.\n\nError:\n{error_message}")
        output_text.config(state=tk.DISABLED)
    except Exception as e:
        messagebox.showerror("Error", f"Terjadi kesalahan yang tidak terduga:\n{str(e)}")

def leave_network():
    global polling_job
    if polling_job:
        app.after_cancel(polling_job)
        polling_job = None

    """Keluar dari jaringan yang saat ini ada di input box."""
    network_id = entry_network_id.get()
    if not network_id:
        messagebox.showerror("Error", "Tidak ada Network ID untuk ditinggalkan.")
        return

    try:
        command = get_cli_command(["leave", network_id])
        result = subprocess.run(command, input=SUDO_PASSWORD, capture_output=True, text=True, check=True)
        
        if "200 leave OK" in result.stdout:
            update_output(f"Berhasil keluar dari jaringan {network_id}")
            # Atur GUI ke mode 'terputus'
            entry_network_id.config(state=tk.NORMAL)
            entry_network_id.delete(0, tk.END)
            action_button.config(text="Join Network", command=join_network)

    except subprocess.CalledProcessError as e:
        update_output(f"Gagal keluar dari jaringan.\n\nError:\n{e.stderr}")
    except Exception as e:
        messagebox.showerror("Error", f"Terjadi kesalahan: {str(e)}")

def save_network(network_info):
    """Menyimpan detail jaringan ke file JSON."""
    try:
        try:
            with open(SAVED_NETWORKS_FILE, 'r') as f:
                networks = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            networks = []

        # Hindari duplikat
        if not any(net['nwid'] == network_info['nwid'] for net in networks):
            networks.append(network_info)
            with open(SAVED_NETWORKS_FILE, 'w') as f:
                json.dump(networks, f, indent=4)

    except Exception as e:
        print(f"Gagal menyimpan jaringan: {e}") # Log ke konsol, tidak mengganggu user

def disable_ui():
    """Menonaktifkan komponen UI utama saat terjadi error fatal."""
    entry_network_id.config(state=tk.DISABLED)
    action_button.config(state=tk.DISABLED)
    saved_button.config(state=tk.DISABLED)    
    # Ubah tombol service menjadi 'Start' karena UI dinonaktifkan saat service mati
    service_button.config(text="Start Service", command=start_zerotier_service, state=tk.NORMAL)

def enable_ui():
    """Mengaktifkan kembali komponen UI utama dan menyembunyikan tombol start service."""
    entry_network_id.config(state=tk.NORMAL)
    action_button.config(state=tk.NORMAL)
    saved_button.config(state=tk.NORMAL)    

def start_zerotier_service():
    """Mencoba memulai service ZeroTier menggunakan metode yang umum."""
    # Nonaktifkan tombol selama proses berjalan
    service_button.config(state=tk.DISABLED)
    update_output("Mencoba memulai service ZeroTier...")
    app.update_idletasks()

    # Daftar perintah untuk dicoba secara berurutan
    commands_to_try = [
        ["systemctl", "start", "zerotier-one.service"],
        ["snap", "start", "zerotier-one"],
        ["snap", "start", "zerotier"],
        ["service", "zerotier-one", "start"]
    ]
    
    for cmd_parts in commands_to_try:
        command_name = cmd_parts[0]
        if find_command(command_name):
            try:
                if SUDO_PASSWORD is not None and SUDO_PASSWORD != "":
                    run_command = ['sudo', '-S'] + cmd_parts
                elif SUDO_PASSWORD is not None:
                    run_command = ['sudo'] + cmd_parts
                else: # Sudah root
                    run_command = cmd_parts
                subprocess.run(run_command, input=SUDO_PASSWORD, check=True, capture_output=True, text=True)
                
                # Beri jeda sesaat agar service sempat berjalan sebelum verifikasi
                update_output(f"Service dimulai dengan '{command_name}'. Memverifikasi status...")
                app.update_idletasks()
                app.after(1500, check_connection_status) # Jadwalkan pemeriksaan ulang
                return # Keluar dari fungsi jika perintah berhasil
            except (subprocess.CalledProcessError, FileNotFoundError):
                continue # Coba perintah berikutnya jika gagal

    # Jika semua perintah gagal
    update_output("Gagal memulai service ZeroTier.\n\nPastikan ZeroTier terinstal dan coba jalankan secara manual:\n'sudo systemctl start zerotier-one.service' atau\n'sudo snap start zerotier-one' (atau 'zerotier')")
    service_button.config(state=tk.NORMAL) # Aktifkan kembali tombol

def stop_zerotier_service():
    """Mencoba menghentikan service ZeroTier."""
    service_button.config(state=tk.DISABLED)
    update_output("Mencoba menghentikan service ZeroTier...")
    app.update_idletasks()

    commands_to_try = [
        ["systemctl", "stop", "zerotier-one.service"],
        ["snap", "stop", "zerotier-one"],
        ["snap", "stop", "zerotier"],
        ["service", "zerotier-one", "stop"]
    ]

    stopped = False
    for cmd_parts in commands_to_try:
        command_name = cmd_parts[0]
        if find_command(command_name):
            try:
                if SUDO_PASSWORD is not None and SUDO_PASSWORD != "":
                    run_command = ['sudo', '-S'] + cmd_parts
                elif SUDO_PASSWORD is not None:
                    run_command = ['sudo'] + cmd_parts
                else: # Sudah root
                    run_command = cmd_parts
                subprocess.run(run_command, input=SUDO_PASSWORD, check=True, capture_output=True, text=True)
                stopped = True
                break
            except (subprocess.CalledProcessError, FileNotFoundError):
                continue

    if stopped:
        update_output("Service ZeroTier berhasil dihentikan.")
        # Panggil check_connection_status untuk memperbarui UI sepenuhnya
        app.after(500, check_connection_status)
    else:
        update_output("Gagal menghentikan service ZeroTier.")
        service_button.config(state=tk.NORMAL)

def check_connection_status(network_id_to_watch=None):
    """Memeriksa koneksi saat aplikasi dimulai dan memperbarui GUI."""
    global polling_job
    if polling_job:
        app.after_cancel(polling_job)
        polling_job = None

    # Pastikan UI aktif sebelum mencoba
    enable_ui()

    try:
        command = get_cli_command(["listnetworks", "-j"])
        result = subprocess.run(command, input=SUDO_PASSWORD, capture_output=True, text=True, check=True)
        networks = json.loads(result.stdout)

        # Service berjalan, ubah tombol menjadi 'Stop Service'
        service_button.config(text="Stop Service", command=stop_zerotier_service, state=tk.NORMAL)


        # Tentukan jaringan mana yang akan ditampilkan
        target_nwid = network_id_to_watch if network_id_to_watch else (entry_network_id.get() if entry_network_id.cget('state') == 'disabled' else None)
        
        connected_network = next((net for net in networks if net.get("nwid") == target_nwid), None)
        if not connected_network: # Jika tidak ditemukan, cari koneksi pertama yang aktif
            connected_network = next((net for net in networks if net.get("status") != "PRIVATE"), None)

        if connected_network:
            # Mode Terhubung
            nwid = connected_network.get("nwid")
            name = connected_network.get("name", "(tidak ada nama)")
            status = connected_network.get("status")
            assigned_addresses = connected_network.get("assignedAddresses", [])

            # Perbarui area output
            info = (f"Status Jaringan\n\n"
                    f"Name              : {name}\n"
                    f"ID                : {nwid}\n"
                    f"Status            : {status}\n")
            
            if assigned_addresses:
                # Gabungkan semua alamat IP yang didapat menjadi satu string
                info += f"Managed Address   : {', '.join(assigned_addresses)}\n"

            update_output(info)

            # Perbarui komponen GUI
            entry_network_id.config(state=tk.NORMAL)
            entry_network_id.delete(0, tk.END)
            entry_network_id.insert(0, nwid)
            entry_network_id.config(state=tk.DISABLED)
            action_button.config(text="Leave Network", command=leave_network)

            # Jika status belum OK, jadwalkan pemeriksaan ulang
            if status != "OK" and network_id_to_watch:
                polling_job = app.after(2000, lambda: check_connection_status(network_id_to_watch=nwid))
            elif status == "OK":
                # Simpan jaringan jika koneksi berhasil
                save_network({'nwid': nwid, 'name': name})


        else:
            # Mode Terputus
            update_output("Tidak ada jaringan yang terhubung. Silakan masukkan Network ID.")
            entry_network_id.config(state=tk.NORMAL)
            # Hapus teks hanya jika tidak ada jaringan yang terhubung
            entry_network_id.delete(0, tk.END)
            action_button.config(text="Join Network", command=join_network)

    except FileNotFoundError:
        update_output("Error: Comm 'zerotier-cli' not found.\n\nBe sure ZeroTier is installed correctly")
        disable_ui()
        # Service tidak berjalan atau tidak terinstal, ubah tombol menjadi 'Start Service'
        service_button.config(text="Start Service", command=start_zerotier_service, state=tk.NORMAL)
        messagebox.showerror("Error", "Comm 'zerotier-cli' not found. App function fail.")
    except subprocess.CalledProcessError:
        infoFailService = (
            f"Failed, Need zerotier service.\n"                
            f"Please start service.\n"
        )
        update_output(infoFailService)
        disable_ui()
        # Service tidak berjalan, ubah tombol menjadi 'Start Service'
        service_button.config(text="Start Service", command=start_zerotier_service, state=tk.NORMAL)
    except (json.JSONDecodeError, IndexError):
        # Tidak ada jaringan terhubung atau output JSON kosong
        update_output("Tidak ada jaringan yang terhubung. Silakan masukkan Network ID.")
        # Service berjalan tetapi tidak ada koneksi, tombol tetap 'Stop Service'
        service_button.config(text="Stop Service", command=stop_zerotier_service, state=tk.NORMAL)

def show_saved_networks():
    """Membuka jendela baru untuk menampilkan dan memilih jaringan tersimpan."""
    try:
        with open(SAVED_NETWORKS_FILE, 'r') as f:
            networks = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        messagebox.showinfo("Info", "Belum ada jaringan yang tersimpan.")
        return
    
    if not networks:
        messagebox.showinfo("Info", "Belum ada jaringan yang tersimpan.")
        return

    win = tk.Toplevel(app)
    win.title("Saved Networks")
    win.geometry("450x300")

    # Frame utama untuk jendela pop-up
    popup_main_frame = tk.Frame(win, padx=10, pady=10)
    popup_main_frame.pack(expand=True, fill=tk.BOTH)

    # Frame untuk listbox, meniru gaya output_frame di jendela utama
    listbox_frame = tk.Frame(popup_main_frame, bd=1, relief=tk.SUNKEN)
    listbox_frame.pack(expand=True, fill=tk.BOTH, pady=(0,10))

    listbox = tk.Listbox(listbox_frame, selectmode=tk.SINGLE, borderwidth=0, highlightthickness=0)
    for net in networks:
        listbox.insert(tk.END, f"{net.get('name', '(no name)')} - {net.get('nwid')}")
    listbox.pack(expand=True, fill=tk.BOTH)


    def on_select():
        selected_indices = listbox.curselection()
        if not selected_indices:
            return
        
        selected_network = networks[selected_indices[0]]
        
        # Atur GUI ke mode terputus agar bisa join
        entry_network_id.config(state=tk.NORMAL)
        entry_network_id.delete(0, tk.END)
        entry_network_id.insert(0, selected_network['nwid'])
        action_button.config(text="Join Network", command=join_network)
        update_output(f"Network ID {selected_network['nwid']} dipilih. Klik 'Join Network' untuk terhubung.")
        
        win.destroy()

    def on_delete():
        selected_indices = listbox.curselection()
        if not selected_indices:
            messagebox.showwarning("Peringatan", "Pilih jaringan yang ingin dihapus.", parent=win)
            return
        
        selected_index = selected_indices[0]
        network_str = listbox.get(selected_index)

        if messagebox.askyesno("Konfirmasi Hapus", f"Anda yakin ingin menghapus jaringan ini?\n\n{network_str}", parent=win):
            # Hapus dari listbox
            listbox.delete(selected_index)
            
            # Hapus dari daftar di memori
            del networks[selected_index]
            
            # Tulis kembali file JSON yang sudah diperbarui
            try:
                with open(SAVED_NETWORKS_FILE, 'w') as f:
                    json.dump(networks, f, indent=4)
            except Exception as e:
                messagebox.showerror("Error", f"Gagal memperbarui file: {e}", parent=win)

    # Frame untuk tombol di bagian bawah
    popup_button_frame = tk.Frame(popup_main_frame)
    popup_button_frame.pack(fill='x')

    select_button = tk.Button(popup_button_frame, text="Gunakan Jaringan Ini", command=on_select, state=tk.DISABLED)
    select_button.pack(fill='x', expand=True, pady=(0, 5))
    delete_button = tk.Button(popup_button_frame, text="Hapus Jaringan", command=on_delete, state=tk.DISABLED)
    delete_button.pack(fill='x', expand=True)


    def on_listbox_select(event):
        """Mengaktifkan tombol ketika item di listbox dipilih."""
        # Periksa apakah ada item yang dipilih
        if listbox.curselection():
            select_button.config(state=tk.NORMAL)
            delete_button.config(state=tk.NORMAL)
        else:
            select_button.config(state=tk.DISABLED)
            delete_button.config(state=tk.DISABLED)
    
    listbox.bind('<<ListboxSelect>>', on_listbox_select)

    # Fokuskan jendela baru
    win.transient(app)
    win.grab_set()
    app.wait_window(win)

# --- Setup GUI ---
app = tk.Tk()
app.title("ZeroTier Connector")
app.geometry("700x300") # Anda bisa mengubah ukuran di sini


# Frame untuk padding
main_frame = tk.Frame(app, padx=15, pady=15)
main_frame.pack(expand=True, fill=tk.BOTH)

# Label untuk input Network ID
label_network_id = tk.Label(main_frame, text="Masukkan Network ID:")
label_network_id.pack(pady=(0, 5))

# Entry (kolom input) untuk Network ID
entry_network_id = tk.Entry(main_frame, width=40)
entry_network_id.pack(pady=(0, 10))

# --- Menambahkan key bindings untuk Ctrl+A dan Ctrl+V ---
def select_all(event):
    """Merespons Ctrl+A untuk memilih semua teks."""
    event.widget.select_range(0, 'end')
    return 'break' # Mencegah event lain dieksekusi

def paste_text(event):
    """Merespons Ctrl+V untuk menempelkan teks dari clipboard."""
    if event.widget.cget('state') == 'normal':
        # Jika ada teks yang dipilih, hapus terlebih dahulu
        try:
            if event.widget.selection_present():
                event.widget.delete('sel.first', 'sel.last')
        except tk.TclError:
            # Abaikan jika tidak ada seleksi
            pass
        # Tempel teks dari clipboard di posisi kursor
        event.widget.insert('insert', app.clipboard_get())
    return 'break'

entry_network_id.bind("<Control-a>", select_all)
entry_network_id.bind("<Control-v>", paste_text)

# --- Menambahkan menu klik kanan (Context Menu) ---
context_menu = tk.Menu(app, tearoff=0)
context_menu.add_command(label="Cut", command=lambda: app.focus_get().event_generate("<<Cut>>"))
context_menu.add_command(label="Copy", command=lambda: app.focus_get().event_generate("<<Copy>>"))
context_menu.add_command(label="Paste", command=lambda: app.focus_get().event_generate("<<Paste>>"))

def show_context_menu(event):
    """Menampilkan menu konteks saat klik kanan."""
    # Hanya tampilkan menu jika widget adalah Entry atau Text
    if isinstance(event.widget, (tk.Entry, tk.Text)):
        context_menu.tk_popup(event.x_root, event.y_root)

# Mengikat event klik kanan ke semua widget di dalam aplikasi
app.bind_class("Entry", "<Button-3>", show_context_menu)
app.bind_class("Text", "<Button-3>", show_context_menu)

# Frame untuk bagian bawah (output dan tombol)
bottom_frame = tk.Frame(main_frame)
bottom_frame.pack(pady=(10, 0), expand=True, fill=tk.BOTH)
bottom_frame.columnconfigure(0, weight=3) # Kolom output lebih lebar
bottom_frame.columnconfigure(1, minsize=120) # Kolom tombol dengan lebar tetap
bottom_frame.rowconfigure(0, weight=1) # Izinkan baris untuk berekspansi secara vertikal

# Frame untuk output (sekarang di dalam bottom_frame)
output_frame = tk.Frame(bottom_frame, bd=1, relief=tk.SUNKEN)
output_frame.grid(row=0, column=0, sticky='nsew', padx=(0, 10))

# Widget Text untuk menampilkan output
output_text = tk.Text(output_frame, wrap=tk.WORD, state=tk.DISABLED, height=8)
output_text.pack(expand=True, fill=tk.BOTH)

# Frame untuk menampung tombol-tombol
button_frame = tk.Frame(bottom_frame)
button_frame.grid(row=0, column=1, sticky='n')

# Tombol Aksi (Join/Leave)
action_button = tk.Button(button_frame, text="Join Network", command=join_network, width=20)
action_button.pack(pady=(0, 5))

# Tombol untuk melihat jaringan tersimpan
saved_button = tk.Button(button_frame, text="Lihat Jaringan Tersimpan", command=show_saved_networks, width=20)
saved_button.pack(pady=(5, 0))

# Tombol untuk memulai/menghentikan service
service_button = tk.Button(button_frame, text="Start Service", command=start_zerotier_service, width=20)
service_button.pack(pady=(5, 0))

# Jalankan pemeriksaan hak akses root sebelum memulai loop utama GUI
run_as_root()

# Memeriksa status koneksi saat aplikasi pertama kali dijalankan
app.after(100, check_connection_status)

# Menjalankan aplikasi
app.mainloop()
