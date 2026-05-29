//
//  IntroductionView.swift
//  Zimizip
//
//  Created by Sunny Side-Up on 5/29/26.
//

import SwiftUI

struct IntroductionView: View {
    var body: some View {
       
        VStack{
            
            Spacer()
                .frame(height: 20)
            
            Rectangle()
                .frame(width: 290, height: 372)
            
            Spacer()
                .frame(height: 70)
            
            Text("특별한 순간을\n더 특별하게")
            
            Spacer()
                .frame(height: 16)
            
            Text("서프라이즈를 준비하고\n그날의 모든 순간을 기록하세요")
            
            Spacer()
                .frame(height: 70)
            
            Button("시작하기") {
            
            }
            Spacer()
                .frame(height: 74)
            
        }
    }
}

#Preview {
    IntroductionView()
}
