//
//  CapsuleCreateOverlay.swift
//  Saturdays
//
//  Created by Yining He  on 12/2/25.
//

import SwiftUI

struct CapsuleCreateOverlay: View {
    var dismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 28) {
            
            Spacer()
            
            // Title
            Text("Create New Capsule")
                .font(.headline)
                .foregroundColor(Color(red: 212/255, green: 212/255, blue: 255/255))
                .padding(.top, 10)

            HStack(spacing: 40) {
                
                // MEMORY BUTTON
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 110, height: 110)
                            .shadow(radius: 8)
                        
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 38)
                            .foregroundColor(.black)
                    }
                    Text("Memory")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                
                // LETTER BUTTON
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 110, height: 110)
                            .shadow(radius: 8)
                        
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                            .foregroundColor(.black)
                    }
                    Text("Letter")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
            
            Spacer().frame(height: 90)   // Lift above the nav bar
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
        .animation(.spring(), value: 1)
    }
}
