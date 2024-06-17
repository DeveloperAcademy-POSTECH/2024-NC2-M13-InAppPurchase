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
    let pictures = [
        Picture(name: "Sample1"),
        Picture(name: "Sample2"),
        Picture(name: "Sample3"),
        Picture(name: "Sample4"),
        Picture(name: "Sample5"),
        Picture(name: "Sample6"),
        Picture(name: "Sample7"),
        Picture(name: "Sample8"),
        Picture(name: "Sample9")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(pictures) { picture in
                        Image(picture.name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130, alignment: .center)
                            .clipped()
                            .onTapGesture {
                                selectedPicture = picture
                            }
                    }
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

//#Preview {
//    GridView()
//}
