//
//  ContentView.swift
//  Shared
//
//  Created by Ryan Grey on 04/03/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var presentImporter = false
    @State var pdfDetails = Welcome(data: [Datum]())
    #if os(tvOS)
    let Hspacing: CGFloat = 50
    let Vspacing: CGFloat = 50
    #else
    let Hspacing: CGFloat = 10
    let Vspacing: CGFloat = 20
    #endif

    #if os(tvOS)
    @State private var numberOfRows = 4
    #else
    @State private var numberOfRows = 2
    #endif
    @State var isActive = false
    @State var selectedUrl = ""
    @State var isLoading = true

    
    var body: some View {

        let columns = Array(
            repeating: GridItem(.flexible(), spacing: Hspacing), count: UIDevice.isIPad ? 3 : numberOfRows)
        return NavigationView{
            ZStack{
                ScrollView {
                                
                                LazyVGrid(columns: columns, spacing: Vspacing){
                #if !os(macOS)
                                    ForEach(0..<self.pdfDetails.data.count, id: \.self) { currentIndex in
                                        NavigationLink(destination:
                                                        
                                                        MyView(pdfLink: self.pdfDetails.data[currentIndex].magazineURL)
                                        )
                                        {
                                            /*ItemView(item : self.pdfDetails.data[currentIndex]) {
                                                selectedUrl = self.pdfDetails.data[currentIndex].magazineURL
                                                isActive = true
                                                print("Button Clicked \(currentIndex)")
                                            }*/
                                            ItemView(item: self.pdfDetails.data[currentIndex])
                                                
                                        }
                                    }
                                    .padding(.horizontal)
                                    Spacer()
                #endif
                                }
                                
                                .background(Color.white)
                                
                            }
                
                if !isLoading {
                    LoaderView(tintColor: .red, scaleSize: 3.0).padding(.bottom,50).hidden(isLoading)
                }
                
            }
            
            .onAppear {
                onLoad()
            }
            .navigationTitle("Magazine")
            
          
#if !os(macOS)
//            if isLoading {
//                ZStack {
//                    Color(UIColor.systemBackground)
//                        .ignoresSafeArea()
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                        .scaleEffect(3)
//                }
//            }
#endif
        }.navigationViewStyle(.stack)
//        .onChange(of: isLoading) { isLoading in
//            if isLoading {
//                startLoading()
//                    ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                    .scaleEffect(3)
//            }
//            else{
//
//            }
//        }
    }
    
    func toggleVar() {
        self.isLoading.toggle()
    }
    
    func onLoad() {
        self.isLoading.toggle()
        Api().loadData { (result) in
            self.pdfDetails = result
            self.isLoading.toggle()
        }
    }
    func startLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isLoading = false
        }
    }
}


struct ItemView: View {
    let item: Datum
#if os(tvOS)
    let vStackSpcing: CGFloat = 40
    #else
    let vStackSpcing: CGFloat = 20
    #endif
//    let onTap: ()->()
    var body: some View {
        GeometryReader{ reader in
            let fontSize = min(reader.size.width * 0.2, 28)
            
            VStack(spacing: vStackSpcing) {
                Image(systemName: "star.fill")
                    .data(url: URL(string: item.magazineThumbnail)!)
                    .resizable()
                    .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
//                    .foregroundColor(.clear)
                Text(item.magazineName.uppercased())
#if os(tvOS)
                    .font(.system(size: 30,weight: .bold, design: .rounded))
                #else
                    .font(.system(size: 18,weight: .bold, design: .rounded))
                #endif
                    
                
                  
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .background(Color.clear)
        }
#if os(tvOS)
        .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
//        .frame(height: UIScreen.main.bounds.height * 1/2)
#else
        .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
#endif
        
//        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#if !os(macOS)
struct MyView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PDFViewController
    @State var pdfLink = ""
    
    func makeUIViewController(context: Context) -> PDFViewController {
        //        let fileURL = Bundle.main.url(forResource: "Sample", withExtension: "pdf")
        let url = URL(string: pdfLink)
        //        print(fileURL as Any)
        let vc = PDFViewController(fileURL: url!, hasCoverPage: true)
        // Do some configurations here if needed.
        return vc!
    }
    
    func updateUIViewController(_ uiViewController: PDFViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
#endif
#if !os(macOS)
extension Image {
    func data(url:URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!)
                .resizable()
        }
        return self
            .resizable()
    }
}
#endif
@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: Double

    func body(content: Content) -> some View {
       let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func scaledFont(name: String, size: Double) -> some View {
        return self.modifier(ScaledFont(name: name, size: size))
    }
}

struct LoaderView: View {
    var tintColor: Color = .blue
    var scaleSize: CGFloat = 1.0
    
    var body: some View {
        ProgressView()
            .scaleEffect(scaleSize, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
    }
}

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
