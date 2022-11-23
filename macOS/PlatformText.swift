//
//  SwiftUIView.swift
//  SwiftUIMultiplatform (macOS)
//
//  Created by Ryan Grey on 04/03/2021.
//
import WebKit
import SwiftUI
import QuickLook
struct Option: Hashable {
    let title : String
    let imageName: String
}

struct PlatformText: View {
    @State var pdfDetails = Welcome(data: [Datum]())
    //@State var wkwebview = WKWebView(
    @State var currentOption = 0
    var body: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 20), count: 5)
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(0..<self.pdfDetails.data.count, id: \.self) {
                        currentIndex in
                    
                        MainView(item: self.pdfDetails.data[currentIndex])
                    }
                }

                }
            
        }.frame(minWidth: 1000, minHeight: 600)
        .onAppear {
                Api().loadData { (result) in
                    self.pdfDetails = result
                }
        }
    }
}
struct MainView: View {
    let item: Datum
    let vStackSpcing: CGFloat = 15
    @State var userGuideUrl: URL?
    @State var webView:WKWebView?
    var body: some View {
        GeometryReader{ reader in
            VStack(spacing: vStackSpcing) {
//                AsyncImage(url: URL(string: item.magazineThumbnail))
                    Image("hello")
                    .resizable()
                    .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
                    .foregroundColor(.clear)
                Text(item.magazineName.uppercased())
                    .foregroundColor(.black)
                    .font(.system(size: 15,weight: .bold, design: .rounded))
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .background(Color.clear)
            }
        .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
        .onTapGesture {
            print("image clicked")
            let request = URL(string: item.magazineURL)
            userGuideUrl = URL(string: item.magazineURL)
                
            
            
        }.quickLookPreview($userGuideUrl)
    }
}

//struct webMacView: NSViewRepresentable {
//    let request: URLRequest
//    func makeNSView(context: Context) -> WKWebView {
//        return WKWebView
//    }
//    func updateNSView(_ nsView: WKWebView, context: Context) {
//        nsView.load(request)
//    }
//}
