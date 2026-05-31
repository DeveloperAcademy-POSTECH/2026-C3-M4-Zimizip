//
//  HomeView.swift
//  Zimizip
//
//  Created by Sunny Side-Up on 6/1/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color(red: 248 / 255, green: 243 / 255, blue: 239 / 255)
                .ignoresSafeArea()

            VStack {
                Text("홈")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 70)
                    .padding(.leading, 20)

                Spacer()

                HStack(spacing: 44) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 25))

                    Image(systemName: "tray.fill")
                        .font(.system(size: 25))
                }
                .foregroundStyle(.white)
                .frame(width: 180, height: 56)
                .background(Color(red: 58 / 255, green: 53 / 255, blue: 50 / 255))
                .clipShape(Capsule())
                .padding(.bottom, 59)
            }
        }
    }
}

#Preview {
    HomeView()
}
