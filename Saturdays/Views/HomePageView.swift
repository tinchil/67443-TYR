//
//  HomePageView.swift
//  Saturdays
//

import SwiftUI

struct HomePageView: View {

    // ViewModels
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var aiPipeline = GeneratedCapsulesPipelineViewModel()
    @EnvironmentObject var auth: AuthViewModel

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
                    VStack(alignment: .leading, spacing: 22) {

                        // MARK: - HEADER
                        headerSection

                        // MARK: - SUBTITLE
                        Text("Create shared capsules to unlock later.")
                            .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                            .font(.headline)
                            .padding(.horizontal)

                        // MARK: - PROMPT
                        PromptCard(prompt: homeVM.promptOfTheDay)
                            .padding(.horizontal)

                        // MARK: - CREATION AREA
                        creationSection

                        // MARK: - ON THIS DAY SECTION
                        if !aiPipeline.onThisDayCapsules.isEmpty {
                            OnThisDaySection(onThisDayCapsules: aiPipeline.onThisDayCapsules)
                                .padding(.horizontal)
                                .padding(.top, 12)
                        }

                        // MARK: - AI GENERATED CAPSULES
                        GeneratedCapsulesSection(
                            capsules: aiPipeline.generatedCapsules,
                            isLoading: aiPipeline.isProcessing
                        )
                        .padding(.horizontal)

                        Spacer(minLength: 120)
                    }
                }
            }
            .navigationDestination(isPresented: $showCreateCapsule) {
                CapsuleDetailsView(viewModel: homeVM.currentCapsuleVM)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissCapsuleFlow"))) { _ in
                showCreateCapsule = false
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Log Out", role: .destructive) {
                            auth.logout()
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                aiPipeline.runPipeline()
            }
        }
    }
}


// --------------------------------------------------
// MARK: - HEADER
// --------------------------------------------------

private extension HomePageView {
    var headerSection: some View {
        HStack {
            Text("Saturdays")
                .font(.largeTitle.bold())

            Image(systemName: "sparkles")
                .font(.title3)

            Spacer()

            NavigationLink {
                FriendsView()
            } label: {
                Image(systemName: "person.3.fill")
                    .font(.title2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 15)
    }
}


// --------------------------------------------------
// MARK: - NEW CAPSULE CREATION SECTION
// --------------------------------------------------

private extension HomePageView {
    var creationSection: some View {
        VStack(spacing: 14) {

            Text("Start a new Capsule")
                .foregroundColor(Color(red: 0, green: 0, blue: 142/255))
                .font(.subheadline.weight(.semibold))
                .opacity(0.4)
                .padding(.horizontal)

            HStack(spacing: 20) {

                MemoryCard {
                    homeVM.startCapsule(type: .memory)
                    showCreateCapsule = true
                }

                LetterCard {
                    homeVM.startCapsule(type: .letter)
                    showCreateCapsule = true
                }
            }
            .padding(.horizontal)

            Text("Choose a Memory Capsule (photos) or Letter Capsule (messages).")
                .foregroundColor(.secondary)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}


// --------------------------------------------------
// MARK: - ON THIS DAY SECTION
// --------------------------------------------------

struct OnThisDaySection: View {
    let onThisDayCapsules: [GeneratedCapsuleModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("On This Day")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Throwbacks from this same day in past years.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(onThisDayCapsules) { cap in
                        NavigationLink {
                            GeneratedCapsuleDetailView(capsule: cap)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {

                                GeneratedCapsuleThumbnailView(filename: cap.coverPhoto)
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text(cap.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .foregroundColor(.primary)

                                Text("\(cap.photoCount) photos")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 120)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
}
