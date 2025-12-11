//
//  MemoryTimelineView.swift
//  Saturdays
//
//  Created by Claude on 12/7/25.
//

import SwiftUI

// MARK: - Protocol for Testing
protocol TimelineServiceProtocol {
    func fetchUserTimeline(completion: @escaping ([TimelineEvent]) -> Void)
}

// Make your real service conform without changing it
extension TimelineService: TimelineServiceProtocol {}

struct MemoryTimelineView: View {

    // MARK: - State
    @State private var timelineEvents: [TimelineEvent] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    // MARK: - Testable, dependency-injected service
    private let timelineService: TimelineServiceProtocol

    // Default initializer for real app usage
    init(timelineService: TimelineServiceProtocol = TimelineService()) {
        self.timelineService = timelineService
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 245/255, green: 245/255, blue: 250/255)
                    .ignoresSafeArea()

                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your journey...")
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    }
                } else if timelineEvents.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 0) {

                            // Header
                            VStack(spacing: 8) {
                                Text("Your Journey")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))

                                Text("Every milestone tells a story")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 30)

                            // Timeline rows
                            ForEach(Array(timelineEvents.enumerated()), id: \.element.id) { index, event in
                                TimelineEventRow(
                                    event: event,
                                    isFirst: index == 0,
                                    isLast: index == timelineEvents.count - 1
                                )
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(Color(red: 0/255, green: 0/255, blue: 142/255))
                    }
                }
            }
            .onAppear {
                loadTimeline()
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("Your Journey Awaits")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start creating memories by adding friends,\ncreating groups, and making capsules!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Load Timeline
    private func loadTimeline() {
        isLoading = true
        timelineService.fetchUserTimeline { events in
            withAnimation(.easeOut(duration: 0.4)) {
                self.timelineEvents = events
                self.isLoading = false
            }
        }
    }
}

// MARK: - Timeline Event Row (unchanged)
struct TimelineEventRow: View {
    let event: TimelineEvent
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline line and icon
            VStack(spacing: 0) {
                // Line above (hidden if first)
                if !isFirst {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 30)
                }

                // Icon circle
                ZStack {
                    Circle()
                        .fill(eventColor.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Circle()
                        .fill(eventColor)
                        .frame(width: 40, height: 40)

                    Image(systemName: event.type.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Line below (hidden if last)
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .frame(minHeight: 60)
                }
            }
            .frame(width: 50)

            // Event card
            VStack(alignment: .leading, spacing: 8) {
                Text(formattedDate(event.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
    }

    private var eventColor: Color {
        switch event.type.color {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "indigo": return .indigo
        case "yellow": return .yellow
        default: return .blue
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    MemoryTimelineView()
}
