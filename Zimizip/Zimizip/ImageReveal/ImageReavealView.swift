//
//  ImageReavealView.swift
//  Zimizip
//
//  Created by 박채은 on 6/7/26.
//

import SwiftUI

struct ImageReavealView: View {
    var body: some View {
        ZStack{
            Image("IrisO").resizable()
                .frame(width:297, height:446)
            Image("CoverHorse").resizable()
                .frame(width:297, height:446)
            
        }
    }
}

#Preview {
    ImageReavealView()
}
