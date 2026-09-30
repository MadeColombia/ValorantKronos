import SwiftUI

// MARK: - Font Name Constants (shared across files)
struct FontNames {
    static let tungstenBold = "Tungsten-Bold"
    static let tungstenMedium = "Tungsten-Medium"
    static let tungstenSemiBold = "Tungsten-SemiBold"
}

// MARK: - Search Strings
struct AppStrings {
    // SearchWeaponSkin
    static let searchNavigationTitle = "Weapon Skins"
    static let searchPrompt = "Search by name"
    static let doneButton = "Done"
    // Damage group box
    static let damageGroupBoxLabel = "DAMAGE"
    static let chromasGroupBoxLabel = "SKINS"
}

// MARK: - Main View
struct SingleWeaponView: View {
    @Environment(\.dismiss) var dismiss
    let weapon: Weapon
    @State private var showPrincipalTitle: Bool = false
    @State private var scrollOffset: CGFloat = 0

    let fadeThresholdStart: CGFloat = 100
    let fadeThresholdEnd: CGFloat = 40

    var body: some View {
        ZStack {
            Color.almostWhite
                .ignoresSafeArea()

            ScrollView {
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, newValue in
                            self.scrollOffset = newValue
                            self.showPrincipalTitle = newValue <= fadeThresholdEnd
                        }
                }
                .frame(height: 0)

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: -10) {
                            Text(weapon.displayName.uppercased())
                                .font(.custom(FontNames.tungstenBold, size: 64))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text(weapon.formattedCategory.uppercased())
                                .foregroundColor(Color.valorantRED)
                                .font(.custom(FontNames.tungstenBold, size: 24))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .opacity(max(0, (scrollOffset - fadeThresholdEnd) / (fadeThresholdStart - fadeThresholdEnd)))

                    WeaponDetailFile(weapon: weapon)
                }
            }.scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ValorantBackButton()
            }

            ToolbarItem(placement: .principal) {
                Text(weapon.displayName.uppercased())
                    .font(.custom(FontNames.tungstenSemiBold, size: 25))
                    .opacity(showPrincipalTitle ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: showPrincipalTitle)
            }
        }
        .enableSwipeBack()
    }
}

// MARK: - Weapon Detail File (replaces hardcoded WeaponFile)
struct WeaponDetailFile: View {
    let weapon: Weapon
    @State private var isPresentingSheet = false
    @State private var selectedSkinDisplayName: String

    init(weapon: Weapon) {
        self.weapon = weapon
        _selectedSkinDisplayName = State(initialValue: weapon.skins?.first?.displayName ?? "Default Skin")
    }

    private var firstDamageRange: DamageRange? {
        weapon.weaponStats?.damageRanges.first
    }

    var body: some View {
        VStack(spacing: 10) {
            // Skin picker
            GroupBox {
                Button(action: { isPresentingSheet = true }) {
                    VStack(spacing: 0) {
                        HStack {
                            Text(selectedSkinDisplayName)
                                .font(.custom(FontNames.tungstenSemiBold, size: 25))
                                .lineLimit(1)
                                .padding(.vertical, 5)
                                .foregroundColor(Color.deepRed)
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color.deepRed)
                        }
                        // Show the selected skin's display icon
                        let skinIcon = weapon.skins?.first(where: { $0.displayName == selectedSkinDisplayName }).flatMap { $0.displayIcon }
                        CachedAsyncImage(url: URL(string: skinIcon ?? weapon.displayIcon ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit().frame(height: 100)
                            case .failure, .empty:
                                Image(systemName: "photo")
                                    .resizable().scaledToFit().frame(height: 80)
                                    .foregroundStyle(Color.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
            .backgroundStyle(Color.khaki)
            .cornerRadius(20)

            // Stats / Damage
            GroupBox {
                if let stats = weapon.weaponStats {
                    // Damage ranges row
                    if let dmg = firstDamageRange {
                        HStack(spacing: 10) {
                            ShortDataView(metric: "HEAD", data: String(format: "%.0f", dmg.headDamage))
                            ShortDataView(metric: "BODY", data: String(format: "%.0f", dmg.bodyDamage))
                            ShortDataView(metric: "LEGS", data: String(format: "%.0f", dmg.legDamage))
                        }
                        Divider()
                    }
                    HStack(spacing: 10) {
                        LargeDataView(metric: "FIRE RATE", data: String(format: "%.2f", stats.fireRate), unitMesure: "RDS/SEC")
                        LargeDataView(metric: "RUN SPEED", data: String(format: "%.2f", stats.runSpeedMultiplier), unitMesure: "M/SEC")
                        LargeDataView(metric: "EQUIP SPEED", data: String(format: "%.2f", stats.equipTimeSeconds), unitMesure: "SEC")
                    }
                    HStack(spacing: 10) {
                        LargeDataView(metric: "1ST SHOT SPREAD", data: String(format: "%.2f", stats.firstBulletAccuracy), unitMesure: "DEG")
                        LargeDataView(metric: "RELOAD SPEED", data: String(format: "%.2f", stats.reloadTimeSeconds), unitMesure: "SEC")
                        LargeDataView(metric: "MAGAZINE", data: "\(stats.magazineSize)", unitMesure: "RDS")
                    }
                } else {
                    // Melee — no stats
                    Text("Melee weapon — no stats available")
                        .font(.custom(FontNames.tungstenMedium, size: 18))
                        .foregroundStyle(Color.almostWhite)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            } label: {
                HStack {
                    Spacer()
                    Text(AppStrings.damageGroupBoxLabel)
                        .foregroundColor(Color.deepRed)
                        .font(.custom(FontNames.tungstenSemiBold, size: 20))
                    Spacer()
                }
            }
            .backgroundStyle(Color.khaki)
            .cornerRadius(20)

            // Skins carousel
            if let skins = weapon.skins, !skins.isEmpty {
                GroupBox {
                    WeaponSkinsCarousel(skins: skins)
                } label: {
                    HStack {
                        Spacer()
                        Text(AppStrings.chromasGroupBoxLabel)
                            .foregroundColor(Color.deepRed)
                            .font(.custom(FontNames.tungstenSemiBold, size: 20))
                        Spacer()
                    }
                }
                .backgroundStyle(Color.khaki)
                .cornerRadius(20)
            }
        }
        .padding()
        .sheet(isPresented: $isPresentingSheet) {
            SearchWeaponSkin(
                weapons: weapon.skins.flatMap { $0.compactMap { skin in
                    Weapon(
                        uuid: skin.uuid,
                        displayName: skin.displayName ?? skin.uuid,
                        category: weapon.category,
                        displayIcon: skin.displayIcon
                    )
                }} ?? [],
                selectedWeaponDisplayName: $selectedSkinDisplayName
            )
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
        }
    }
}

// MARK: - Weapon Skins Carousel

struct WeaponSkinsCarousel: View {
    let skins: [WeaponSkin]
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            ForEach(skins.indices, id: \.self) { index in
                let skin = skins[index]
                VStack(spacing: 4) {
                    CachedAsyncImage(url: URL(string: skin.displayIcon ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .failure, .empty:
                            Image(systemName: "photo")
                                .resizable().scaledToFit()
                                .foregroundStyle(Color.gray.opacity(0.5))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 80)
                    Text(skin.displayName ?? "")
                        .font(.custom(FontNames.tungstenMedium, size: 14))
                        .foregroundStyle(Color.almostWhite)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                }
                .padding()
                .background(Color.deepRed.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
        .frame(height: 160)
        .cornerRadius(20)
    }
}

// MARK: - ShortDataView

struct ShortDataView: View {
    let metric: String
    let data: String
    
    var body: some View {
        HStack {
            Text(metric)
                .foregroundColor(Color.almostWhite)
                .font(.custom(FontNames.tungstenSemiBold, size: 16))
            Spacer()
            Text(data)
                .foregroundColor(Color.valorantRED)
                .font(.custom(FontNames.tungstenSemiBold, size: 16))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.deepRed)
        .clipShape(RoundedCorner(radius: 10, corners: .allCorners))
    }
}

// MARK: - LargeDataView

struct LargeDataView: View {
    let metric: String
    let data: String
    let unitMesure: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(metric)
                    .foregroundColor(Color.almostWhite)
                    .font(.custom(FontNames.tungstenSemiBold, size: 16))
                Text(data)
                    .foregroundColor(Color.white)
                    .font(.custom(FontNames.tungstenSemiBold, size: 36))
                    .lineLimit(2)
                Text(unitMesure)
                    .foregroundColor(Color.almostWhite)
                    .font(.custom(FontNames.tungstenSemiBold, size: 13))
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.vertical)
        .background(Color.deepRed)
        .clipShape(RoundedCorner(radius: 15, corners: .allCorners))
    }
}

// MARK: - Search Weapon Skin Sheet
struct SearchWeaponSkin: View {
    @Environment(\.dismiss) var dismiss
    
    let weapons: [Weapon]
    @Binding var selectedWeaponDisplayName: String
    @State private var searchText: String = ""
    
    var filteredWeapons: [Weapon] {
        if searchText.isEmpty {
            return weapons
        } else {
            return weapons.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(filteredWeapons) { weapon in
                        HStack {
                            Text(weapon.displayName)
                            Spacer()
                            if selectedWeaponDisplayName == weapon.displayName {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .onTapGesture {
                            selectedWeaponDisplayName = weapon.displayName
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal)
                .listStyle(.plain)
            }
            .toolbarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text(AppStrings.searchPrompt))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text(AppStrings.doneButton)
                            .font(.custom(FontNames.tungstenMedium, size: 25))
                            .foregroundStyle(Color.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(AppStrings.searchNavigationTitle)
                        .font(.custom(FontNames.tungstenMedium, size: 25))
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        SingleWeaponView(weapon: mockWeapon)
    }
}

