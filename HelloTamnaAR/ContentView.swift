//
//  ContentView.swift
//  HelloTamnaAR
//
//  Created by Hyeonsoo Kim on 2022/06/28.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        return ARGestureViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero) //UIKit View의 일종.
        
        //가상 요소를 만들기 전에 어디에 놓을지 생각해야 합니다.
        //이를 위해 Anchor를 생성.
        let anchor = AnchorEntity(plane: .horizontal)
        //수평면을 인식하면 Anchor를 부착. (닻)
        
        
        //anchor에 들어갈 요소. 개체.
        //mesh : 전체 구조, 스켈레톤, 어떤 종류의 객체를 만들고 있는지.(형태? 모양?)
        //자료에 대한 정보를 전달할 수 있는 한 가지 방법.
        //materials: 해당 재료가 금속성인 경우 색상을 전달할 수 있습니다. 또한 빛반사.
        let material = SimpleMaterial(color: .orange, isMetallic: true)
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), //size에 CGFloat 숫자 하나만 넣으면 x,y,z축이 다 그 길이로 되고, 대괄호 열어서 명시적으로 넣으면 각각이 x,y,z 길이이다. 1.0 == 1meter
                              materials: [material]) //size에
        
        //sphere도 추가해보기.
        //'구'도 3d 원형 원이므로 다시 미터 단위의 반경을 갖습니다. radius : 반지름.
        let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.15),
                                 materials: [SimpleMaterial(color: .yellow, isMetallic: true)])
        //parent == anchor center???
        sphere.position = simd_make_float3(0,0.3,0)
        //x:수평좌우, y:위아래, z:앞뒤(가깝고 먼)
        
        //plane == 평면(직사각형). width: 가로, depth: 세로.
        let plane = ModelEntity(mesh: MeshResource.generatePlane(width: 0.5, depth: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        plane.position = simd_make_float3(0, 0.45, 0)
        
        //anchor = 벽에 걸 수 있는 고리(비유)
        anchor.addChild(box)
        anchor.addChild(sphere)
        anchor.addChild(plane)
        
        //만든 anchor를 scene에 추가해주어야함.
        arView.scene.anchors.append(anchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        
    }
    
}

struct ARTextViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let text = ModelEntity(mesh: MeshResource.generateText("Hello, I'm Tamna", //default로 0,0,0에서부터 글자가 시작되서 첫글자부터 보인다.
                                                               extrusionDepth: 0.03, //text의 깊이?크기?
                                                               font: .systemFont(ofSize: 0.2, weight: .black), //size도 meter단위임.
                                                               containerFrame: .zero,
                                                               //text가 표시될 실제 frame. -> zero를 하면 컨테이너가 다음에 따라 텍스트를 담을 수 있을만큼 충분히 크다는 의미. 그냥 무제한 한 줄.
                                                               alignment: .center, //여러 줄일 때 정렬기준.
                                                               lineBreakMode: .byCharWrapping), //frame보다 클때 어떻게 하냐는 건가.
                               materials: [SimpleMaterial(color: .orange, isMetallic: true)])
        
        anchor.addChild(text)
        
        arView.scene.anchors.append(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}

struct ARGestureViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)                           //context가 뭘까...실제로 반응해주는 놈은 coordinator다.
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        //arView가 탭 제스쳐 이벤트를 수신할 책임이 있음을 의미.
        
        //모든 다른 제스쳐에 대해 모든 다른 delegate 기능은 coordinator가 처리합니다.
        //본디 UIKit코드에선 delegate위임을 self로 그 View가 받지만, UIKit in SwiftUI코드에선 실제 SwiftUI에 반영하기위해 coordinator를 필수로 구현해야한다. 그렇기에 delegate도 coordinator가 위임받는 것.
        context.coordinator.view = arView //coordinator는 view를 알고있음. //TODO: ?
        arView.session.delegate = context.coordinator //delegate를 초기 상태 context의 coordinator에 위임하기. //TODO: ?
        //arView.session의 이벤트는 코디네이터에게 위임되고 코디네이터는 책임을 집니다. (이벤트를 처리하기위해)
        
        let anchor = AnchorEntity(plane: .horizontal) //scene의 중심에 위치 잡힘.
        
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: .yellow, isMetallic: true)])
        
        box.generateCollisionShapes(recursive: true) //gesture동작 시 필수. 충돌감지를 해야 Tap도 감지하는 듯.
        
        anchor.addChild(box)
        
        arView.scene.anchors.append(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator2 { //코디네이터 지정.
        Coordinator2()
        // Coordinator의 경우 UIKit -> SwiftUI로의 데이터 전달이라고 생각하면 쉽다.Coordinator라고 해서 새로운 개념 같지만, 사실상 "delegate"의 역할을 한다고 봐도 무방하다.
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

/*
 # default
 - anchor type : Plane (수평면)
 - anchor material : 콘크리트
 - entity material : steel (강철) - 빛 반사 유무: 유
 - y height: 5cm
 - entity size 10x10x10
 */
