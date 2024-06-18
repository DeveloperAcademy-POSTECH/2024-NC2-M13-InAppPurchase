//
//  GridView.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/17/24.
//

import SwiftUI

struct Picture: Identifiable {
    let id = UUID()
    let name: String
    var mustPurchase: Bool = false
}

struct GridView: View {
    @State private var selectedPicture: Picture? = nil
    @State private var showPurchaseView = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let pictures: [Picture] = (1...20).map { Picture(name: "Sample\($0)", mustPurchase: $0 > 4) }
    

    // 평생구매시 mustPurchase = false로 바꾸면 됨, 근데 10장 구매일 경우는 어떻게 처리하지?
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let itemSize = (width - 10) / 3
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 3) {
                        if itemSize > 0 {
                            ForEach(pictures) { picture in
                                let isPurchased = !picture.mustPurchase || selectedPicture?.id == picture.id
                                
                                Image(picture.name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: itemSize, height: itemSize)
                                    .blur(radius: isPurchased ? 0 : 6)
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
                    pictures.append(Picture(name: pictureName))
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
