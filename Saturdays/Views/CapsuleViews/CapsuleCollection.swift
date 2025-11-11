//
//  CapsuleCollection.swift
//  Saturdays
//
//  Created by Yining He  on 12/1/25.
//

import SwiftUI

struct CapsuleCollection: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.white, Color(red: 0.94, green: 0.95, blue: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - HEADER
                        HStack {
                            Text("Your Capsules")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Image(systemName: "sparkles")
                                .font(.title3)
                        }
                    }
                }
            }
        }
    }
}
                     
#Preview {
    CapsuleCollection()
}


