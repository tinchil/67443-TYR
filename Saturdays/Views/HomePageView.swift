//
//  HomePageView.swift
//  Saturdays
//
//  Created by Claude Code
//

import SwiftUI

struct HomePageView: View {

    // ViewModels
    @StateObject private var homeVM = HomeViewModel()
    @State private var showCreateCapsule = false
    
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
                            Text("Saturdays")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Image(systemName: "sparkles")
                                .font(.title3)
                            
                            Spacer()
                            
                            Image(systemName: "person.3.fill")
                                .font(.title2)
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
        
                        
                        // MARK: - SUBTITLE
                        Text("Create shared capsules to unlock later.")
                            .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                            .font(.headline)
                            .fontWeight(.regular)
                            .padding(.horizontal)
                        
                        
                        // MARK: - PROMPT OF THE DAY
                        PromptCard(prompt: homeVM.promptOfTheDay)
                            .padding(.horizontal)
                        
                        
                        // MARK: - START NEW CAPSULE
                        Text("Start a new Capsule")
                            .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .opacity(0.4)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            
                            // Memory capsule button
                            MemoryCard {
                                homeVM.startCapsule(type: .memory)
                                showCreateCapsule = true
                            }
                            
                            // Letter capsule button
                            LetterCard {
                                homeVM.startCapsule(type: .letter)
                                showCreateCapsule = true
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        // MARK: - DESCRIPTION
                        Text("Choose a Memory Capsule (photos) or Letter Capsule (messages) to unlock later.")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer(minLength: 80)
                    }
                }
            }
            .navigationDestination(isPresented: $showCreateCapsule) {
                CapsuleDetailsView(viewModel: homeVM.currentCapsuleVM)
            }
        }
    }
}

#Preview {
    HomePageView()
}

