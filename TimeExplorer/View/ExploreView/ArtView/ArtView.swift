//
//  ArtView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 09/04/2021.
//

import SwiftUI
import SceneKit
import AVKit
import SUI

struct FrameReader: PreferenceKey {
	
	static var defaultValue: CGRect = .zero
	
	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}

struct AnnotationData:Codable,Hashable,Loopable{
    var heading:String?
    var detail:String?
}

struct ArtView: View {
    @State var data:ArtData
    @EnvironmentObject var mainStates:AppStates
    @Binding var showArt:Bool
    @StateObject var viewStates:ArtViewStates = .init()
    @Namespace var animation
    @State var mainTab:Int = 0
    @State var annotationTab:String = ""
    @State var inspect:Bool = false
    @State var tabData:[(heading:String,detail:String,key:String?)]? = nil
    @State var showInfoCard:Bool = false
    @State var viewAR:Bool = false
	@State var onLoad: Bool = false
	
    var tabs:[String] = ["Introduction","Top Features","Top Facts"]
    init(data:ArtData,showArt : Binding<Bool> = .constant(false)){
        self._data = State(initialValue: data)
        self._showArt = showArt
    }
    
    //MARK: - Header
    var header:some View{
        HStack{
            if self.viewStates.inspect{
                SystemButton(b_name: "xmark", b_content: "",color: .black,bgcolor: .white) {
                    self.viewStates.inspect.toggle()
                }
                //                Spacer()
                //                MainText(content: self.viewStates.changes ? "Update" : self.data.title, fontSize: 15, color: .white, fontWeight: .bold, style: .normal)
                //                    .padding()
                //                    .background(BlurView(style: .dark))
                //                    .clipShape(RoundedRectangle(cornerRadius: 20))
                //                    .onTapGesture(perform: self.updateArtData)
                //                Spacer()
            }
            
        }
        .padding(.top, .safeAreaInsets.top)
        .fillWidth(alignment: .trailing)
    }
    
    //MARK: - Sidebars
    
    func sideBar(w:CGFloat) -> some View{
        return  HStack(alignment: .top, spacing: 10) {
            Spacer()
            VStack(alignment: .center, spacing: 10) {
//                TabBarButtons(bindingState: $viewStates.showFeatures, name: "sparkles")
//                TabBarButtons(bindingState: $viewStates.isEditting,name: "pencil")
                TabBarButtons(bindingState: $viewAR, name: "cube")
            }
        }.padding()
        .frame(width: w, alignment: .trailing)
    }
    
    
    
    //MARK: - TabViews
    
    func infoRow(w:CGFloat,h:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10){
            ScrollView(.vertical, showsIndicators: false){
                MainText(content: self.data.introduction, fontSize: 15, color: .black, fontWeight: .semibold, style: .normal)
            }
        }.padding()
        .frame(width: w - 20, height: h - 20, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
    
    
    func annotationTab(w:CGFloat,h:CGFloat) -> some View{
        let cardDetails = self.viewStates.annotationInfos[self.viewStates.selectedAnnotation]
        let video = self.viewStates.annotationVideo[self.viewStates.selectedAnnotation]
        return FactCard(q: cardDetails?.heading ?? "no Question", ans: cardDetails?.detail ?? "no Detail", width: w, height: h * (video != nil ? 1.5 : 1),vid_url: video)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    //MARK: - updateStates
    func updateAnnotations(){
        if self.viewStates.annotationHeading != "" && self.viewStates.annotationDetail != ""{
            let ann_data:AnnotationData = .init(heading: viewStates.annotationHeading, detail: viewStates.annotationDetail)
            self.viewStates.annotationInfos[viewStates.selectedAnnotation] = ann_data
            self.viewStates.resetAnnotationState()
            self.viewStates.changes = true
        }
    }
    
    
    func updateArtData(){
        if self.viewStates.changes{
            self.data.annotations = self.viewStates.annotations.keys.compactMap({ (key) -> FIRAnnotationData? in
                guard let coord = self.viewStates.annotations[key], let info = self.viewStates.annotationInfos[key] else {return nil}
                return .init(x: coord.x, y: coord.y, z: coord.z, heading: info.heading, detail: info.detail, name: key)
            })
            self.mainStates.AAPI.updateArt(self.data)
        }
    }
    
    func doneButton(w:CGFloat) -> some View{
        return Button {
            self.updateAnnotations()
            if self.viewStates.openModal{
                self.viewStates.openModal = false
            }
            if self.viewStates.isEditting{
                self.viewStates.isEditting = false
            }
        } label: {
            MainText(content: "Done", fontSize: 10, color: .white, fontWeight: .semibold)
                .padding()
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }.frame(width:w,alignment:.bottomTrailing)
    }
    
    func annotationEditBox(w width:CGFloat,h height:CGFloat) -> some View{
        let view =
            GeometryReader{g in
                let w = g.frame(in: .local).width
                let h = g.frame(in: .local).height
                VStack(alignment:.leading,spacing:10){
                    TextField("Annotation Heading", text: $viewStates.annotationHeading)
                        .frame(width: w, height: h * 0.1, alignment: .topLeading)
                    MainText(content: "Add Details Below", fontSize: 12, color: .black, fontWeight: .semibold)
                    TextEditor(text: $viewStates.annotationDetail)
                        .frame(width: w, height: h * 0.6, alignment: .topLeading)
                    self.doneButton(w: w)
                    Spacer()
                }.frame(width: w, height: h, alignment: .center)
            }
            .padding()
            .padding(.top,40)
            .frame(width: width, height: height, alignment: .topLeading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
        return view
    }
    
    func onAppear(){
        if self.mainStates.showTab{
            self.mainStates.toggleTab()
        }
        
        if let annotations = self.data.annotations{
            let (infos,coords,video) = ArtViewStates.updateAnnotations(annotations: annotations)
            DispatchQueue.main.async {
                self.viewStates.annotations = coords
                self.viewStates.annotationInfos = infos
                self.viewStates.annotationVideo = video
            }
        }
        
    }
    
    func updateAfterSceneInteraction(name:String,vector:SCNVector3?){
        DispatchQueue.main.async {
            if self.viewStates.selectedAnnotation != ""{
                self.viewStates.selectedAnnotation = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    self.viewStates.selectedAnnotation = name
                }
            }else{
                self.viewStates.selectedAnnotation = name
            }
            
            self.viewStates.tappedLocation = vector
        }
        
    }
    
    
    //MARK: - Micellaneous
    var name: String{
        get{
            return self.data.title.split(separator: " ")
                .reduce("") { (res, str) -> String in
                    return res == "" ? String(str) : "\(res)_\(str)"
                } + ".usdz"
                
        }
    }

    //MARK: - SceneView
    @ViewBuilder func sceneView(w: CGFloat, h: CGFloat) -> some View {
        let radius = self.viewStates.inspect ? 0 : 15
        if let model_url  = self.data.model_url{
         SceneModelView(w: w, h: h, name: self.name, model_url_str: model_url, player: nil, handler: self.updateAfterSceneInteraction(name:vector:))
                .environmentObject(viewStates)
                .background(BlurView(style: .dark))
                .clipShape(Corners(rect: .bottomRight,size: .init(width: radius, height: radius)))
        } else if let img = self.data.model_img{
            SceneModelView(w: w, h: h, name: self.name, img_url_str: img, player: nil, handler: self.updateAfterSceneInteraction(name:vector:))
                .environmentObject(viewStates)
                .background(BlurView(style: .dark))
                .clipShape(Corners(rect: .bottomRight,size: .init(width: radius, height: radius)))
        }
    }
    
    func addAnnotationButton(w:CGFloat,h:CGFloat) -> some View{
        return HStack(alignment: .center, spacing: 10) {
            Spacer()
            SystemButton(b_name: "plus", b_content: "") {
                self.viewStates.openModal = true
            }
            MainText(content: "Add/Edit Modal", fontSize: 15, color: .black, fontWeight: .semibold)
            Spacer()
        }.padding()
        .frame(width: w, height: h, alignment: .center)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .onTapGesture {
            self.viewStates.openModal = true
        }
    }
    
    
    func infoBody(w width: CGFloat,h height:CGFloat) -> some View{
        return GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            ZStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 25){
                    if !self.viewStates.isEditting{
                        self.header.padding()
                        Spacer()
                        if self.viewStates.inspect{
                            if self.viewStates.selectedAnnotation != ""{
                                self.annotationTab(w:w,h:h * 0.3)
                            }
                        }
                    }
                    if self.viewStates.isEditting{
                        self.addAnnotationButton(w: w, h: h * 0.2)
                        Spacer()
                    }
                    
                }.frame(width: w, alignment: .bottom).animation(.easeInOut)
                if self.viewStates.inspect{
                    self.sideBar(w: w)
                }
                
            }.frame(width: w, height: h, alignment: .center)
            
            
        }
        .padding()
        .padding(.vertical,30)
        .frame(width: width, height: height, alignment: .center)
    }
    
    func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    func mainScene(w:CGFloat = totalWidth,h:CGFloat = totalHeight) -> some View{
        return ZStack(alignment: .top){
            if let safeSceneView = self.sceneView(w: w, h: h){
                safeSceneView
            }
            self.infoBody(w: w, h: h)
            if self.viewStates.inspect{
                if self.viewStates.isEditting &&  self.viewStates.openModal{
                    BlurView(style: .regular)
                        .frame(width: w, height: h, alignment: .center)
                        .onTapGesture {
                            self.resignFirstResponder()
                        }
                    VStack(alignment: .leading, spacing: 10) {
                        self.annotationEditBox(w: w, h: h * 0.4)
                        Spacer()
                    }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
                }
            }
        }.frame(width: w, height: h, alignment: .center)
    }
    
    func IntroInfoBody(w:CGFloat,h:CGFloat) -> some View{
        return FactCard(q: self.data.title, ans: self.data.introduction, width: w * 0.95, height: h * 0.40)
    }
    
    func mainBody(w:CGFloat,h:CGFloat) -> some View{
        ZStack(alignment: .center){
            self.mainScene(w: totalWidth, h: totalHeight)
            if !self.viewStates.inspect{
				lightbottomShadow
					.fillFrame()
                VStack(alignment: .leading, spacing: 10){
					"AR Experience"
						.heading1()
						.text
                    SystemButton(b_name: "cube", b_content: "View",color: .black,bgcolor: .white) {
                        DispatchQueue.main.async {
                            self.viewStates.inspect = true
                        }
                    }
                }.padding(20)
				.fillFrame(alignment: .bottomLeading)
            }
            
        }
		.framed(size: .init(width: .totalWidth, height: .totalHeight), cornerRadius: 0, alignment: .center)
		.fullScreenModal(isActive: $viewAR, config: .init(isDraggable: true, showCloseIndicator: true)) {
			ARMainView(name: self.name, model_url: self.data.model_url, img_url: self.data.model_img, show: $viewAR)
				.environmentObject(viewStates)
		}
		.scrollToggle(state: !viewStates.inspect)
    }
    
    var body: some View {
		mainBody(w: .totalWidth, h: .totalHeight)
			.frame(width: totalWidth, height: totalHeight, alignment: .center)
			.background(Color.white)
			.onDisappear(perform: {
				if !self.mainStates.showTab && self.mainStates.tab != "attractions"{
					self.mainStates.showTab = true
				}
			})
			.onChange(of: self.viewStates.selectedAnnotation, perform: { annotation in
				if self.showInfoCard{
					self.showInfoCard.toggle()
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
					self.showInfoCard.toggle()
				}
			})
    }
}



var test : ArtData = .init(date: Date(), title: "Mona Lisa", model_url: "https://firebasestorage.googleapis.com/v0/b/trippin-89b8b.appspot.com/o/models%2FMona_Lisa_PBR_hires_model.usdz?alt=media&token=506bb277-8a3a-4b64-8ec8-4fd42d1c81e1", introduction: "Mona Lisa, also called Portrait of Lisa Gherardini, wife of Francesco del Giocondo, Italian La Gioconda, or French La Joconde, oil painting on a poplar wood panel by Leonardo da Vinci, probably the world’s most famous painting. It was painted sometime between 1503 and 1519, when Leonardo was living in Florence, and it now hangs in the Louvre Museum, Paris, where it remained an object of pilgrimage in the 21st century. The sitter’s mysterious smile and her unproven identity have made the painting a source of ongoing investigation and fascination.", infoSnippets:["Location": "Lovre , Paris","A1": "An1","A2": "An2"],top_facts: ["Question 1":"Leonardo da Vinci began painting the Mona Lisa in 1503, and it was in his studio when he died in 1519. He likely worked on it intermittently over several years, adding multiple layers of thin oil glazes at different times. Small cracks in the paint, called craquelure, appear throughout the whole piece, but they are finer on the hands, where the thinner glazes correspond to Leonardo’s late period.","Question 2":"The Mona Lisa is priceless. Any speculative price (some say over a billion dollars!) would probably be so high that not one person would be able or willing to purchase and maintain the painting. Moreover, the Louvre Museum would probably never sell it. The museum attracts millions of visitors each year, most of whom come for the Mona Lisa, so a steady stream of revenue may be more lucrative in the long run than a single payment. Indeed, the museum considers the Mona Lisa irreplaceable and thus spends its resources on preventive measures to maintain the portrait rather than on expensive insurance that can only offer mere money as a replacement."], thumbnail: "https://firebasestorage.googleapis.com/v0/b/trippin-89b8b.appspot.com/o/thumbnailsImages%2Fmona_lisa.jpeg?alt=media&token=91d77859-541f-47d5-92b9-f6ba6fc1b386")

struct ArtView_Previews: PreviewProvider {
    static var previews: some View {
        ArtView(data: test)
    }
}
