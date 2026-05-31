//
//  SurprizepreparingView.swift
//  Zimizip
//
//  Created by Sunny Side-Up on 6/1/26.
//


import SwiftUI

struct StartMethodView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 248 / 255, green: 243 / 255, blue: 239 / 255)
                .ignoresSafeArea()

            Button {
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.75))
                    .clipShape(Circle())
            }
            .padding(.leading, 20)
            .padding(.top, 70)

            VStack(alignment: .leading, spacing: 16) {
                Text("어떤 방식으로\n시작해볼까요?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))

                Text("서프라이즈 사진을 준비하는\n방법을 선택해주세요")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(red: 129 / 255, green: 121 / 255, blue: 115 / 255))
                    .lineSpacing(4)
            }
            .padding(.leading, 21)
            .padding(.top, 138)

            methodCard(
                icon: "camera",
                title: "직접 촬영하기",
                subtitle: "서프라이즈를 할 순간을\n바로 담아보세요",
                selected: false
            )
            .padding(.leading, 20)
            .padding(.top, 332)

            methodCard(
                icon: "photo",
                title: "갤러리에서 불러오기",
                subtitle: "이미 저장된 사진으로\n시작해보세요",
                selected: false
            )
            .padding(.leading, 20)
            .padding(.top, 480)
        }
        .ignoresSafeArea()
    }

    func methodCard(icon: String, title: String, subtitle: String, selected: Bool) -> some View {
        HStack(spacing: 25) {
            Circle()
                .fill(selected ? Color(red: 218 / 255, green: 207 / 255, blue: 200 / 255) : Color(red: 239 / 255, green: 231 / 255, blue: 225 / 255))
                .frame(width: 86, height: 86)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.13))
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 129 / 255, green: 121 / 255, blue: 115 / 255))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
        }
        .padding(.horizontal, 15)
        .frame(width: 361)
        .frame(height: 128)
        .background(selected ? Color(red: 239 / 255, green: 228 / 255, blue: 220 / 255) : .clear)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 215 / 255, green: 206 / 255, blue: 200 / 255), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StartMethodView()
}
