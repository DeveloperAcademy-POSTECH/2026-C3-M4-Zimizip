//
//  PhotoFramingView.swift
//  Zimizip
//
//  Created by Mason's Mac on 6/5/26.
//

import SwiftUI

struct PhotoFramingView: View {
    let media: Data
    let cancelButtonAction: () -> Void
    let completeButtonAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PhotoFramingTopBar(
                cancelButtonAction: cancelButtonAction,
                completeButtonAction: completeButtonAction
            )

            PhotoFramingEditingArea()

            PhotoFramingBackgroundPanelPlaceholder()
        }
        .background(Color.black)
    }
}

private struct PhotoFramingTopBar: View {
    let cancelButtonAction: () -> Void
    let completeButtonAction: () -> Void

    var body: some View {
        HStack {
            Button("취소") {
                cancelButtonAction()
            }
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(.white)
            .frame(width: 56, alignment: .leading)
            .buttonStyle(.plain)

            Spacer()

            Text("사진 배치")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button("완료") {
                completeButtonAction()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 56, alignment: .trailing)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.black)
    }
}

private struct PhotoFramingEditingArea: View {
    var body: some View {
        ZStack {
            Color.black
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PhotoFramingBackgroundPanelPlaceholder: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("배경색")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.37, blue: 0.0))

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()
                .frame(height: 92)
        }
        .background(Color(red: 0.12, green: 0.10, blue: 0.09))
    }
}

#Preview {
    PhotoFramingView(
        media: Data(),
        cancelButtonAction: {},
        completeButtonAction: {}
    )
}
