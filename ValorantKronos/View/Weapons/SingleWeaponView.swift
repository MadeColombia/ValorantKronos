import SwiftUI

// MARK: - Constants for Strings and Fonts
struct AppStrings {
    // SingleWeaponView
    static let phantomTitle = "PHANTOM"
    static let rifleSubtitle = "RIFLE"
    static let weaponsNavBackButton = "Weapons"

    // WeaponFile & Components
    static let defaultSkinName = "Phantom OG Skin"
    static let damageGroupBoxLabel = "DAMAGE"
    static let chromasGroupBoxLabel = "CROMAS"
    static let defaultChromaCardImage = "WeaponsImage" // For the static ChromaCard in WeaponFile button

    // Stats Data (Example for Phantom)
    static let headDamage = "195"; static let headMetric = "HEAD"
    static let bodyDamage = "65";  static let bodyMetric = "BODY"
    static let legsDamage = "48";  static let legsMetric = "LEGS"

    static let fireRate = "5.25"; static let fireRateMetric = "FIRE RATE"; static let rdsSecUnit = "RDS/SEC"
    static let runSpeed = "5.4";  static let runSpeedMetric = "RUN SPEED"; static let mSecUnit = "M/SEC"
    static let equipSpeed = "1";   static let equipSpeedMetric = "EQUIP SPEED"; static let secUnit = "SEC"
    
    static let firstShotSpread = "0.1/0"; static let firstShotSpreadMetric = "1ST SHOT SPREAD"; static let degHipAdsUnit = "DEG (HIP/ADS)"
    static let reloadSpeed = "2.5"; static let reloadSpeedMetric = "RELOAD SPEED" // secUnit is reused
    static let magazineSize = "12"; static let magazineMetric = "MAGAZINE"; static let rdsUnit = "RDS"

    // ChromasCarrousel
    static let chromaImageNames = ["1", "2", "3", "4", "5"]

    // SearchWeaponSkin
    static let searchNavigationTitle = "Weapon Skins"
    static let searchPrompt = "Search by name"
    static let doneButton = "Done"
}

struct FontNames {
    static let tungstenBold = "Tungsten-Bold"
    static let tungstenMedium = "Tungsten-Medium"
    static let tungstenSemiBold = "Tungsten-SemiBold"
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
                        VStack(alignment: .leading ,spacing: -10) {
                            Text(AppStrings.phantomTitle)
                                .font(.custom(FontNames.tungstenBold, size: 64))
                                .lineLimit(1)
                            Text(AppStrings.rifleSubtitle)
                                .foregroundColor(Color.valorantRED)
                                .font(.custom(FontNames.tungstenBold, size: 24))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .opacity(max(0, (scrollOffset - fadeThresholdEnd) / (fadeThresholdStart - fadeThresholdEnd)))

                    WeaponFile()
                }
            }.scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    HStack(spacing: 5){
                        Image(systemName: "chevron.backward")
                        Text(AppStrings.weaponsNavBackButton)
                            .font(.custom(FontNames.tungstenMedium, size: 22))
                    }.foregroundStyle(Color.slightlyBlack)
                })
            }

            ToolbarItem(placement: .principal) {
                Text(AppStrings.phantomTitle)
                    .font(.custom(FontNames.tungstenSemiBold, size: 25))
                    .opacity(showPrincipalTitle ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: showPrincipalTitle)
            }
        }
    }
}

// MARK: - Weapon File and Components
struct WeaponFile: View {
    @StateObject var viewModel = WeaponsViewModel()
    @State private var isPresentingSheet = false
    @State private var selectedSkinDisplayName: String = AppStrings.defaultSkinName
    
    var body: some View {
        VStack(spacing: 10) {
            GroupBox {
                Button(action: { isPresentingSheet = true }) {
                    VStack(spacing: 0) {
                        HStack {
                            Text(selectedSkinDisplayName)
                                .font(.custom(FontNames.tungstenSemiBold, size: 25))
                                .lineLimit(1)
                                .padding(.vertical,5)
                                .foregroundColor(Color.deepRed)
                            
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color.deepRed)
                        }
                        ChromaCard(imageName: AppStrings.defaultChromaCardImage)
                            .padding(5)
                    }
                }
            }
            .backgroundStyle(Color.khaki)
            .cornerRadius(20)
            
            GroupBox {
                HStack(spacing: 10) {
                    ShortDataView(metric: AppStrings.headMetric, data: AppStrings.headDamage)
                    ShortDataView(metric: AppStrings.bodyMetric, data: AppStrings.bodyDamage)
                    ShortDataView(metric: AppStrings.legsMetric, data: AppStrings.legsDamage)
                }
                Divider()
                HStack(spacing: 10) {
                    LargeDataView(metric: AppStrings.fireRateMetric, data: AppStrings.fireRate, unitMesure: AppStrings.rdsSecUnit)
                    LargeDataView(metric: AppStrings.runSpeedMetric, data: AppStrings.runSpeed, unitMesure: AppStrings.mSecUnit)
                    LargeDataView(metric: AppStrings.equipSpeedMetric, data: AppStrings.equipSpeed, unitMesure: AppStrings.secUnit)
                }
                HStack(spacing: 10) {
                    LargeDataView(metric: AppStrings.firstShotSpreadMetric, data: AppStrings.firstShotSpread, unitMesure: AppStrings.degHipAdsUnit)
                    LargeDataView(metric: AppStrings.reloadSpeedMetric, data: AppStrings.reloadSpeed, unitMesure: AppStrings.secUnit)
                    LargeDataView(metric: AppStrings.magazineMetric, data: AppStrings.magazineSize, unitMesure: AppStrings.rdsUnit)
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
            
            GroupBox {
                ChromasCarrousel()
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
        .padding()
        .sheet(isPresented: $isPresentingSheet) {
            SearchWeaponSkin(weapons: viewModel.weapons, selectedWeaponDisplayName: $selectedSkinDisplayName)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
    }
}

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

struct ChromasCarrousel: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection : $selection) {
            ForEach(AppStrings.chromaImageNames.indices, id: \.self) { index in
                ChromaCard(imageName: AppStrings.chromaImageNames[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
        .frame(height: 250)
        .cornerRadius(20)
    }
}

struct ChromaCard: View {
    let imageName: String

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
        .padding()
        .background(Color.red.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

// MARK: - Search View
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
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text(AppStrings.doneButton)
                            .font(.custom(FontNames.tungstenMedium, size: 25))
                            .foregroundStyle(Color.black)
                    })
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

