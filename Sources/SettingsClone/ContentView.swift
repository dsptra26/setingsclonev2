import SwiftUI

struct CleanBluetoothLogo: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.32, y: h * 0.24))
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.50))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.88))
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.50))
        path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.76))
        return path
    }
}

struct CircleBackButton: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button(action: { dismiss() }) {
            ZStack {
                Circle().fill(Color(white: 0.22)).frame(width: 32, height: 32)
                Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            }
        }
    }
}

struct iOSGroupModifier: ViewModifier {
    func body(content: Content) -> View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .padding(.horizontal, 16)
    }
}

extension View {
    func iOSGroupedContainer() -> some View {
        self.modifier(iOSGroupModifier())
    }
}

@main
struct SettingsCloneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @AppStorage("isUnlocked") private var isUnlocked = false
    @AppStorage("activationTimestamp") private var activationTimestamp: Double = 0
    
    @State private var inputCode = ""
    @State private var errorMessage = false
    @State private var isServerBlocked = false
    @State private var isLoading = true
    
    let validDailyCode = "IPHONE2026"
    let firebaseURL = "https://setingsclone-default-rtdb.asia-southeast1.firebasedatabase.app/access_control/status.json"

    var body: some View {
        Group {
            if isLoading {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            } else if isServerBlocked {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 50)).foregroundColor(.red)
                        Text("Akses Dimatikan").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                        Text("Akses aplikasi ini telah dihentikan oleh administrator.").font(.system(size: 14)).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 40)
                    }
                }
            } else if isUnlocked && (Date().timeIntervalSince1970 - activationTimestamp < 86400) {
                SettingsMainView()
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "lock.shield.fill").font(.system(size: 50)).foregroundColor(.blue)
                        Text("Aktivasi Perangkat").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                        Text("Masukkan kode akses harian yang diberikan untuk menggunakan aplikasi.").font(.system(size: 14)).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 30)
                        SecureField("Masukkan Kode Harian", text: $inputCode)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color(white: 0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                        if errorMessage {
                            Text("Kode akses salah!").font(.system(size: 13)).foregroundColor(.red)
                        }
                        Button(action: {
                            if inputCode == validDailyCode {
                                isUnlocked = true
                                activationTimestamp = Date().timeIntervalSince1970
                                errorMessage = false
                            } else {
                                errorMessage = true
                            }
                        }) {
                            Text("Masuk & Aktifkan").font(.system(size: 16, weight: .semibold)).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
        }
        .onAppear {
            checkServerKillSwitchREST()
        }
    }
    
    func checkServerKillSwitchREST() {
        guard let url = URL(string: firebaseURL) else {
            self.isLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data, let rawString = String(data: data, encoding: .utf8) {
                    let status = rawString.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if status == "blocked" {
                        self.isServerBlocked = true
                    } else {
                        self.isServerBlocked = false
                    }
                }
                self.isLoading = false
            }
        }.resume()
    }
}

struct SettingsMainView: View {
    @State private var isAirplaneModeOn = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea(.all)
                ScrollView {
                    VStack(spacing: 20) {
                        // Section 1: Profil
                        HStack(spacing: 16) {
                            Circle().fill(LinearGradient(colors: [Color(red: 0.25, green: 0.58, blue: 0.68), Color(red: 0.10, green: 0.25, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 62, height: 62)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Suhana").font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                                Text("Akun Apple, iCloud, dan lainnya").font(.system(size: 13)).foregroundColor(Color(white: 0.6))
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(white: 0.4))
                        }
                        .padding(.vertical, 6).iOSGroupedContainer().padding(.top, 8)
                        
                        // Section 2: Update iOS
                        HStack {
                            Text("Perbarui ke iOS 27.0.1").font(.system(size: 16)).foregroundColor(.white)
                            Spacer()
                            ZStack {
                                Circle().fill(Color.red).frame(width: 20, height: 20)
                                Text("1").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                            }
                            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(white: 0.4))
                        }
                        .padding(.vertical, 6).iOSGroupedContainer()
                        
                        // Section 3: Konektivitas
                        VStack(spacing: 0) {
                            HStack {
                                SettingsIcon(systemName: "airplane", backgroundColor: .orange)
                                Text("Mode Pesawat").font(.system(size: 16)).foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $isAirplaneModeOn).labelsHidden()
                            }.padding(.vertical, 10)
                            Divider().background(Color(white: 0.2))
                            HStack {
                                SettingsIcon(systemName: "wifi", backgroundColor: .blue)
                                Text("Wi-Fi").font(.system(size: 16)).foregroundColor(.white)
                                Spacer()
                                Text("Terhubung").font(.system(size: 15)).foregroundColor(Color(white: 0.5))
                            }.padding(.vertical, 10)
                            Divider().background(Color(white: 0.2))
                            HStack {
                                CustomBluetoothIcon()
                                Text("Bluetooth").font(.system(size: 16)).foregroundColor(.white)
                                Spacer()
                                Text("Tidak Terhubung").font(.system(size: 15)).foregroundColor(Color(white: 0.5))
                            }.padding(.vertical, 10)
                            Divider().background(Color(white: 0.2))
                            HStack {
                                SettingsIcon(systemName: "antenna.radiowaves.left.and.right", backgroundColor: .green)
                                Text("Seluler").font(.system(size: 16)).foregroundColor(.white)
                                Spacer()
                                Text("Mati").font(.system(size: 15)).foregroundColor(Color(white: 0.5))
                            }.padding(.vertical, 10)
                        }.iOSGroupedContainer()
                        
                        // Section 4: Menu Utama
                        VStack(spacing: 0) {
                            NavigationLink(destination: GeneralSettingsView()) {
                                HStack {
                                    SettingsIcon(systemName: "gear", backgroundColor: .gray)
                                    Text("Umum").font(.system(size: 16)).foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(white: 0.4))
                                }.padding(.vertical, 10)
                            }
                            Divider().background(Color(white: 0.2))
                            HStack {
                                SettingsIcon(systemName: "accessibility", backgroundColor: .blue)
                                Text("Aksesibilitas").font(.system(size: 16)).foregroundColor(.white)
                                Spacer()
                            }.padding(.vertical, 10)
                            Divider().background(Color(white: 0.2))
                            HStack {
                                SettingsIcon(systemName: "sparkles", backgroundColor: Color(red: 0.92, green: 0.35, blue: 0.18))
                                Text("Apple Intelligence & Siri").font(.system(size: 16)).foregroundColor(.white)
                                Spacer()
                            }.padding(.vertical, 10)
                        }.iOSGroupedContainer()
                        
                        Spacer().frame(height: 85)
                    }
                }
                .navigationTitle("Pengaturan")
                
                // Floating Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass").foregroundColor(Color.white.opacity(0.6)).font(.system(size: 16, weight: .semibold))
                    TextField("Cari", text: $searchText).font(.system(size: 17)).foregroundColor(.white)
                    Image(systemName: "mic.fill").foregroundColor(Color.white.opacity(0.6)).font(.system(size: 16))
                }
                .padding(.horizontal, 16).padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(white: 0.15, opacity: 0.50))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                )
                .padding(.horizontal, 16).padding(.bottom, 8)
            }
        }
    }
}

struct CustomBluetoothIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous).fill(Color(red: 0.0, green: 0.48, blue: 1.0)).frame(width: 29, height: 29)
            CleanBluetoothLogo().stroke(Color.white, style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round)).frame(width: 13, height: 18)
        }.padding(.trailing, 6)
    }
}

struct SettingsIcon: View {
    let systemName: String
    let backgroundColor: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous).fill(backgroundColor).frame(width: 29, height: 29)
            Image(systemName: systemName).font(.system(size: 15, weight: .medium)).foregroundColor(.white)
        }.padding(.trailing, 6)
    }
}

// Menu "Umum"
struct GeneralSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 0) {
                    NavigationLink(destination: AboutSettingsView()) {
                        HStack {
                            Text("Mengenai").foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(white: 0.4))
                        }.padding(.vertical, 12)
                    }
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Pembaruan Perangkat Lunak").foregroundColor(.white); Spacer() }.padding(.vertical, 12)
                }.iOSGroupedContainer()
                
                VStack(spacing: 0) {
                    NavigationLink(destination: VPNManagementView()) {
                        HStack {
                            Text("Manajemen VPN & Perangkat").foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(white: 0.4))
                        }.padding(.vertical, 12)
                    }
                }.iOSGroupedContainer()
            }
            .padding(.top, 12)
        }
        .navigationTitle("Umum")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { CircleBackButton() }
        }
        .background(Color.black)
    }
}

// Menu "Mengenai" (Lengkap dengan seluruh detail aslinya)
struct AboutSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 0) {
                    HStack { Text("Nama"); Spacer(); Text("iPhone Suhana").foregroundColor(.gray) }.padding(.vertical, 11)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Versi iOS"); Spacer(); Text("26.5").foregroundColor(.gray) }.padding(.vertical, 11)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Nama Model"); Spacer(); Text("iPhone 17 Pro Max").foregroundColor(.gray) }.padding(.vertical, 11)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Nomor Model"); Spacer(); Text("MFYP4PA/A").foregroundColor(.gray) }.padding(.vertical, 11)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Nomor Seri"); Spacer(); Text("KJX6WK6357").foregroundColor(.gray) }.padding(.vertical, 11)
                }
                .iOSGroupedContainer()
                
                VStack(spacing: 0) {
                    HStack { Text("Garansi Terbatas"); Spacer(); Text("Kedaluwarsa pada 27/12/26").foregroundColor(.gray) }.padding(.vertical, 12)
                }
                .iOSGroupedContainer()
                
                VStack(spacing: 0) {
                    HStack { Text("Lagu"); Spacer(); Text("0").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Video"); Spacer(); Text("1.029").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Foto"); Spacer(); Text("7.862").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Aplikasi"); Spacer(); Text("39").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Kapasitas"); Spacer(); Text("256 GB").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Tersedia"); Spacer(); Text("157,19 GB").foregroundColor(.gray) }.padding(.vertical, 10)
                }
                .iOSGroupedContainer()
                
                VStack(spacing: 0) {
                    HStack { Text("Alamat Wi-Fi"); Spacer(); Text("B8:01:1F:BA:90:38").foregroundColor(.gray) }.padding(.vertical, 9)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Bluetooth"); Spacer(); Text("B8:01:1F:B8:D8:67").foregroundColor(.gray) }.padding(.vertical, 9)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Firmware Modem"); Spacer(); Text("1.60.02").foregroundColor(.gray) }.padding(.vertical, 9)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("SEID"); Spacer(); Text("").foregroundColor(.gray) }.padding(.vertical, 9)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("EID"); Spacer(); Text("89049032020008884800234954216871").font(.system(size: 13)).foregroundColor(.gray) }.padding(.vertical, 9)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Kunci Operator"); Spacer(); Text("Tidak ada pembatasan SIM").foregroundColor(.gray) }.padding(.vertical, 9)
                }
                .iOSGroupedContainer()
                
                VStack(spacing: 0) {
                    HStack { Text("Jaringan"); Spacer(); Text("INDOSATOOREDOO").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("Operator"); Spacer(); Text("INDOSAT 70.0").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("IMEI"); Spacer(); Text("35 260231 063492 5").foregroundColor(.gray) }.padding(.vertical, 10)
                    Divider().background(Color(white: 0.2))
                    HStack { Text("ICCID"); Spacer(); Text("89620130003168785752").font(.system(size: 13)).foregroundColor(.gray) }.padding(.vertical, 10)
                }
                .iOSGroupedContainer()
                
                VStack(spacing: 0) {
                    HStack { Text("IMEI2"); Spacer(); Text("35 260231 067993 8").foregroundColor(.gray) }.padding(.vertical, 12)
                }
                .iOSGroupedContainer()
                
                VStack(spacing: 0) {
                    NavigationLink(destination: CertificateTrustView()) {
                        HStack {
                            Text("Pengaturan Kepercayaan Sertifikat").foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(white: 0.4))
                        }
                        .padding(.vertical, 12)
                    }
                }
                .iOSGroupedContainer()
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .navigationTitle("Mengenai")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { CircleBackButton() }
        }
        .background(Color.black)
    }
}

// Menu "Pengaturan Kepercayaan Sertifikat"
struct CertificateTrustView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Versi Stok Sertifikat").foregroundColor(.white)
                        Spacer()
                        Text("2026040100").foregroundColor(.gray)
                    }
                    .padding(.vertical, 12)
                    
                    Divider().background(Color(white: 0.2))
                    
                    HStack {
                        Text("Versi Aset Kepercayaan").foregroundColor(.white)
                        Spacer()
                        Text("1013").foregroundColor(.gray)
                    }
                    .padding(.vertical, 12)
                }
                .iOSGroupedContainer()
            }
            .padding(.top, 12)
        }
        .navigationTitle("Pengaturan Kepercayaan Sertifikat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { CircleBackButton() }
        }
        .background(Color.black)
    }
}

// Menu "VPN"
struct VPNManagementView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    SettingsIcon(systemName: "network", backgroundColor: .blue)
                    Text("VPN").font(.system(size: 16)).foregroundColor(.white)
                    Spacer()
                    Text("Tidak Terhubung").foregroundColor(.gray)
                }.padding(.vertical, 12)
            }.iOSGroupedContainer()
            .padding(.top, 12)
        }
        .navigationTitle("Manajemen VPN & Perangkat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { CircleBackButton() }
        }
        .background(Color.black)
    }
}
