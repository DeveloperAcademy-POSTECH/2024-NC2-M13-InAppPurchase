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
}

struct GridView: View {
    @State private var selectedPicture: Picture? = nil
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let pictures: [Picture] = (1...13).map { Picture(name: "Sample\($0)") }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let itemSize = (width - 5) / 3
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 3) {
                        ForEach(pictures) { picture in
                            if itemSize > 0 {
                                Image(picture.name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: itemSize, height: itemSize)
                                    .clipped()
                                    .onTapGesture {
                                        selectedPicture = picture
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 3)
                }
            }
            .fullScreenCover(item: $selectedPicture) { picture in
                ZStack {
                    Image(picture.name)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            selectedPicture = nil
                        }
                }
            }
        }
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
