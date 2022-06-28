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
        return ARViewContainer()
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
        
        //plane == 평면. width: 가로, depth: 세로.
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
