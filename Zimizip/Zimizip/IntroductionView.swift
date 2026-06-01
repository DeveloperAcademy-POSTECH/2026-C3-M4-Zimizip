//
//  IntroductionView.swift
//  Zimizip
//
//  Created by Sunny Side-Up on 5/29/26.
//

import SwiftUI

struct IntroductionView: View {
    var body: some View {
        ZStack {
            Color(red: 248 / 255, green: 243 / 255, blue: 239 / 255)
                .ignoresSafeArea()

            VStack {
                Spacer()
                    .frame(height: 430)

                Text("상대를 깜짝 놀라게 할 사진을\n예쁘게 포장하고 슬쩍 건네보세요")
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.center)

                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(red: 1, green: 0.42, blue: 0.13))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.top, 53)

                Spacer()
                
                Button("다음") {
                    
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(red: 1, green: 0.42, blue: 0.13))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
                .padding(.bottom, 59)
            }
        }
    }
}

#Preview {
    IntroductionView()
}
