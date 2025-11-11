//
//  BottomNavBar.swift
//  Saturdays
//
//  Created by Yining He  on 12/1/25.
//

import SwiftUI

enum Tab {
    case home
    case capsules
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tab
    var createAction: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.black)
                .frame(height: 70)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                .padding(.horizontal, 24)
            
            HStack {
                navButton(icon: "house.fill", label: "Home", isSelected: selectedTab == .home) {
                    selectedTab = .home
                }
                
                Spacer()
                
                navButton(icon: "archivebox.fill", label: "Capsules", isSelected: selectedTab == .capsules) {
                    selectedTab = .capsules
                }
            }
            .padding(.horizontal, 70)
            
            VStack {
                Button(action: {
                    createAction()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 212/255, green: 212/255, blue: 255/255))
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.2), radius: 6, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                .offset(y: -30)
            }
        }
        .frame(height: 90)
        .padding(.bottom, 10)
    }
    
    func navButton(icon: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .fontWeight(isSelected ? .bold : .regular)
            }
        }
    }
}

