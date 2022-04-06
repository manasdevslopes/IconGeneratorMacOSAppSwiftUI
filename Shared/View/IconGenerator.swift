//
//  IconGenerator.swift
//  IconGenerator
//
//  Created by MANAS VIJAYWARGIYA on 06/04/22.
//

import SwiftUI

struct IconGenerator: View {
    @StateObject var iconModel: IconGeneratorViewModel = IconGeneratorViewModel()
    
    // MARK: - Adapting environment values for dark / light mode
    @Environment(\.self) var env
    
    var body: some View {
        VStack(spacing: 15) {
            if let image = iconModel.pickedImage {
                Group {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 250)
                        .clipped()
                    
                    Button(action: {
                        iconModel.generateIconSet()
                    }) {
                        Text("Generate Icon Set")
                            .foregroundColor(env.colorScheme == .dark ? .black : .white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 18)
                            .background(.primary, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 10)
                }
            } else {
                ZStack {
                    Button(action: {
                        iconModel.PickImage()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(env.colorScheme == .dark ? .black : .white)
                            .padding(15)
                            .background(.primary, in: RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Text("1024 x 1024 is recommended!")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .frame(width: 400, height: 400)
        .buttonStyle(.plain)
        .alert(iconModel.alertMsg, isPresented: $iconModel.showAlert) {
            
        }
        .overlay {
            ZStack {
                if iconModel.isGenerating {
                    Color.black.opacity(0.25)
                    ProgressView()
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 10))
                        .environment(\.colorScheme, .light)
                    
                }
            }
        }
        .animation(.easeInOut, value: iconModel.isGenerating)
    }
}

struct IconGenerator_Previews: PreviewProvider {
    static var previews: some View {
        IconGenerator()
    }
}
