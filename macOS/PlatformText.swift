//
//  SwiftUIView.swift
//  SwiftUIMultiplatform (macOS)
//
//  Created by Ryan Grey on 04/03/2021.
//
import WebKit
import SwiftUI
import QuickLook
import TPPDF
import PDFKit
import AppKit

struct PDFKitRepresentedView: NSViewRepresentable {
    
    var url: URL?
    @Binding var currentPage: Int
    @Binding var total: Int
   
    init(_ url: URL, _ currentPage: Binding<Int>, _ total: Binding<Int>) {
        self.url = url
        self._currentPage = currentPage
        self._total = total
    }
    
    func makeNSView(context: NSViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.NSViewType {
        guard let document = PDFDocument(url: self.url!) else { return NSView() }
        let pdfView = PDFView()
        if let url = self.url {
            pdfView.document = PDFDocument(url: url)
            pdfView.autoScales = true
            pdfView.displayDirection = .vertical
//            pdfView.usePageViewController(true)
        } else {
            pdfView.document = nil
        }
        DispatchQueue.main.async {
            self.total = document.pageCount
            print("Total pages: \(total)")
        }
        return pdfView
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<PDFKitRepresentedView>) {
        guard let pdfView = nsView as? PDFView else {
            return
        }
        if currentPage < total {
                    pdfView.go(to: pdfView.document!.page(at: currentPage)!)
                }
        if let url = self.url {
            pdfView.document = PDFDocument(url: url)
        } else {
            pdfView.document = nil
        }
    }
}
struct Option: Hashable {
    let title : String
    let imageName: String
}

struct HomePage: View {
    var pdfDetails = Welcome(data: [Datum]())
    @State var currentPage: Int = 0
    @State var total: Int = 0
    @State var pdfUrl = ""
    @State var page = 0
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<self.pdfDetails.data.count, id: \.self ) { currentIndex in
                    VStack {
                        AsyncImage(url: URL(string: pdfDetails.data[currentIndex].magazineThumbnail)) { image in
                            image.resizable()
                                .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
                            
                        } placeholder: {
                            ProgressView()
                        }
                        
                        
                        Text("\(pdfDetails.data[currentIndex].magazineName)")
                        
                        Spacer()
                        
                    }
                        .onTapGesture {
                            pdfUrl = self.pdfDetails.data[currentIndex].magazineURL
                            print(pdfUrl)
                        }
                    
                    
                    
                }
            }.frame(minWidth: 100, idealWidth: 200, maxWidth: 300,
                    minHeight: 0, maxHeight: .infinity,
                    alignment: .topLeading)
             .listStyle(SidebarListStyle())
            VStack {
                let pdfView = PDFView()
                let pdfLink = URL(string: pdfUrl)
                if pdfLink != nil {
//                    Button("<") { currentPage -= 1 }.padding()
//                        .disabled(currentPage == 0)
//                    Button(">") { currentPage += 1 }.padding()
//                        .disabled(currentPage == total - 1)
                    
                    PDFKitRepresentedView(pdfLink!, $currentPage, $total)
                }else {
                    //                PDFKitRepresentedView(url: URL(string: pdfDetails.data[0].magazineURL))
                    Text("MAGAZINE APPLICATION")
                }
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
           
            
        }
        .navigationTitle("Magazine")
        .frame(minWidth: 600, minHeight: 400)
        .toolbar {
            ToolbarItem(id: "test") {
                Button(action: toggleSidebar, label: { // 1
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }
    private func toggleSidebar() { // 2
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        
    }
    
}
struct PlatformText: View {
    @State var pdfDetails = Welcome(data: [Datum]())
    
    //@State var wkwebview = WKWebView(
    @State var currentOption = 0
    var body: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 20), count: 5)
        //        NavigationView {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(0..<self.pdfDetails.data.count, id: \.self) {
                        currentIndex in
                        
                        
                        
                        MainView(item: self.pdfDetails.data[currentIndex])
                        
                        
                        
                    }
                }
                
                
            }
            .onAppear {
                Api().loadData { (result) in
                    self.pdfDetails = result
                }
            }
        }
        //        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct MainView: View {
    let item: Datum
    let vStackSpcing: CGFloat = 15
    @State var userGuideUrl: URL?
    @State var webView:WKWebView?
    @State var ispush: Bool = false
    var body: some View {
        
        GeometryReader{ reader in
            VStack(spacing: vStackSpcing) {
                AsyncImage(url: URL(string: item.magazineThumbnail)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
                Text(item.magazineName.uppercased())
                    .foregroundColor(.white)
                    .font(.system(size: 15,weight: .bold, design: .rounded))
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .background(Color.clear)
        }
        .aspectRatio(CGSize(width: 1, height: 1.5),contentMode: .fit)
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
        .onTapGesture {
            print(item.magazineURL)
            //            ShowPdf()
            ispush = true
          
            
        }
    }
}

//struct pdfView : View {
//    var urlString: String
//    var body: some View {
//        PDFKitRepresentedView(url: URL(string: urlString), page: <#Binding<Int>#>)
//    }
//}
