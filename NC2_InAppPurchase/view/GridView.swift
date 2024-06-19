//
//  GridView.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/17/24.
//

import SwiftUI

class Picture: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    @Published var mustPurchase: Bool
    
    init(name: String, mustPurchase: Bool) {
        self.name = name
        self.mustPurchase = mustPurchase
    }
}

struct GridView: View {
    @State private var selectedPicture: Picture? = nil
    @State private var showPurchaseView = false
    
    @ObservedObject var store: Store  // Add Store as an ObservedObject
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let itemSize = (width - 6) / 3
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 3) {
                        if itemSize > 0 {
                            ForEach(store.pictures) { picture in
                                let isPurchased = !picture.mustPurchase
                                
                                Image(picture.name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: itemSize, height: itemSize)
                                    .blur(radius: isPurchased ? 0 : 7)
                                    .clipped()
                                    .onTapGesture {
                                        if isPurchased {
                                            selectedPicture = picture
                                        } else {
                                            showPurchaseView = true
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 3)
                }
            }
            .fullScreenCover(item: $selectedPicture) { picture in
                ZStack {
                    Color(red: 232 / 255, green: 228 / 255, blue: 210 / 255).ignoresSafeArea()
                    Image(picture.name)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            selectedPicture = nil
                        }
                }
            }
            .sheet(isPresented: $showPurchaseView) {
                PurchaseView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 232 / 255, green: 228 / 255, blue: 210 / 255))
    }
}

// Assets에서 사진을 이름별로 더 쉽게 불러오기 위함
func loadPictures(prefix: String) -> [Picture] {
    let fileManager = FileManager.default
    var pictures: [Picture] = []
    
    // Assuming all the images are stored in the main bundle
    if let path = Bundle.main.resourcePath {
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path)
            for item in items {
                if item.hasPrefix(prefix) {
                    let pictureName = item.replacingOccurrences(of: ".png", with: "") // adjust based on the file extension
                    pictures.append(Picture(name: pictureName, mustPurchase: false))
                }
            }
        } catch {
            print("Error reading contents of directory: \(error.localizedDescription)")
        }
    }
    
    return pictures
}

//#Preview {
//    GridView()
//}
