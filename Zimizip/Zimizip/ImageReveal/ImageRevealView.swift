//
//  ImageRevealView.swift
//  Zimizip
//
//  Created by 박채은 on 6/7/26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageRevealView: View {
    
    let bottomImage: UIImage? = UIImage(named: "IrisO")
    let coverImage = UIImage(named: "CoverHorse")
    var ciBottomImage: CIImage? {UItoCI(uiimage:bottomImage)}
    var ciCoverImage: CIImage? {UItoCI(uiimage:coverImage)}
    
    func UItoCI(uiimage:UIImage?) -> CIImage? {
        guard let uiimage else {
            return nil
        }
        
        guard let ciBottomImage = CIImage(image: uiimage) else {
            return nil
        }
        return ciBottomImage
    }
    
    var body: some View {
        ZStack{
            Image("IrisO").resizable()
                .frame(width:297, height:446)
            Image("CoverHorse").resizable()
                .frame(width:297, height:446)
            
        }
    }
    
    private func applyCoreImageReveal(bottom: UIImage, cover: UIImage, mask: UIImage) -> UIImage? {
        
        // [1단계: 재료 준비하기]
        // 화면용 이미지(UIImage)를 필터용 이미지(CIImage)로 변환합니다.
        guard let bottomCI = CIImage(image: bottom),
              let coverCI = CIImage(image: cover),
              let maskCI = CIImage(image: mask) else { return nil }
        
        // [2단계: 필터(효과) 적용하기]
        // 프리미어 프로의 합성 효과를 적용하는 것과 같습니다.
        let filter = CIFilter.blendWithMask()
        filter.inputImage = bottomCI       // 뚫린 구멍 사이로 보여줄 '진짜 이미지' (아래 트랙)
        filter.backgroundImage = coverCI   // 아직 안 뚫린 '커버 이미지' (위 트랙)
        filter.maskImage = maskCI          // 내가 손가락으로 그린 '마스크 모양' (알파 매트)
        
        // [3단계: 렌더링(추출)하기]
        // 필터가 적용된 결과물을 다시 화면에 띄울 수 있는 일반 이미지로 뽑아냅니다.
        if let outputCI = filter.outputImage {
            let context = CIContext() // 렌더링을 도와주는 엔진
            if let cgImage = context.createCGImage(outputCI, from: outputCI.extent) {
                return UIImage(cgImage: cgImage) // 최종 완성본 반환!
            }
        }
        
        return nil // 실패하면 아무것도 안 줌
    }
}



#Preview {
    ImageRevealView()
}
