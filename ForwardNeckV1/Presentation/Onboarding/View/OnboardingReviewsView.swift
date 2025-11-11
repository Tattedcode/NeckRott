import SwiftUI

/// Final onboarding screen that shows friendly reviews and a 5-star rating prompt.
struct OnboardingReviewsView: View {
    /// Simple review model so we can loop without repeating layout code.
    private let reviews: [Review] = [
        Review(
            id: "aaron",
            name: "Aaron",
            quote: "My neck pain is gone after just 2 weeks! The quick workouts actually work."
        ),
        Review(
            id: "karina",
            name: "Karina",
            quote: "I love tracking my progress. Seeing my streaks motivates me to stay consistent."
        ),
        Review(
            id: "mike",
            name: "Mike",
            quote: "Finally found something that fits my busy schedule. 2 minutes and I'm done!"
        )
    ]

    @State private var showHeader = false
    @State private var visibleReviewCount = 0
    @State private var showStats = false

    var body: some View {
        VStack(spacing: 28) {
            ratingHeader
                .opacity(showHeader ? 1 : 0)
                .offset(y: showHeader ? 0 : 20)

            // Statistics Section
            statisticsSection
                .opacity(showStats ? 1 : 0)
                .offset(y: showStats ? 0 : 20)

            communityRow

            VStack(spacing: 18) {
                ForEach(Array(reviews.enumerated()), id: \.element.id) { index, review in
                    ReviewCard(review: review)
                        .opacity(index < visibleReviewCount ? 1 : 0)
                        .offset(y: index < visibleReviewCount ? 0 : 24)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            Log.info("OnboardingReviewsView appeared – revealing reviews")
            withAnimation(.easeOut(duration: 0.5)) {
                showHeader = true
            }
            
            // Show stats after header
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showStats = true
                }
            }

            // Stagger in the review cards so the screen feels alive.
            reviews.indices.forEach { index in
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.25 + 0.6) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        visibleReviewCount = index + 1
                    }
                }
            }
        }
    }

    /// Top section that mirrors the screenshot layout with title and star bar.
    private var ratingHeader: some View {
        VStack(spacing: 16) {
            Text("How this app helps your neck")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .frame(height: 70)
                .overlay(starRow)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Give us a rating, five stars selected")
    }

    /// Row of 5 glowing stars so kiddos instantly know what to tap.
    private var starRow: some View {
        HStack(spacing: 18) {
            ForEach(0..<5) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color.yellow)
                    .shadow(color: Color.yellow.opacity(0.6), radius: 4, x: 0, y: 2)
            }
        }
    }

    /// Statistics section showing impressive numbers
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    number: "60%",
                    label: "Less neck pain",
                    subtitle: "in 2 weeks"
                )
                
                StatCard(
                    number: "2 min",
                    label: "Daily workouts",
                    subtitle: "quick & effective"
                )
            }
            
            HStack(spacing: 20) {
                StatCard(
                    number: "10K+",
                    label: "Happy users",
                    subtitle: "worldwide"
                )
                
                StatCard(
                    number: "4.8★",
                    label: "App rating",
                    subtitle: "on App Store"
                )
            }
        }
        .padding(.horizontal, 8)
    }

    /// Middle row that shows happy users and the +30,000 label.
    private var communityRow: some View {
        VStack(spacing: 12) {
            Text("Join thousands of users improving their neck health")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            HStack(spacing: -16) {
                // Use real portraits from assets for community avatars
                ForEach(0..<3) { index in
                    let imageName: String = {
                        switch index {
                        case 0: return "portrait1"
                        case 1: return "portrait2"
                        default: return "portrait3"
                        }
                    }()

                    ZStack {
                        // Fallback placeholder background
                        Circle()
                            .fill(Color.white.opacity(0.2))

                        // Portrait image clipped to circle
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                            .accessibilityHidden(true)
                    }
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.top, 4)

            Text("+30,000 neckrot users")
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Review Model & Card

private extension OnboardingReviewsView {
    struct Review: Identifiable {
        let id: String
        let name: String
        let quote: String
    }
    
    /// Statistics card component
    struct StatCard: View {
        let number: String
        let label: String
        let subtitle: String
        
        var body: some View {
            VStack(spacing: 4) {
                Text(number)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.black.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    /// Card that mimics the rounded testimonial blocks from the mockup.
    struct ReviewCard: View {
        let review: Review

        private var portraitName: String {
            switch review.id {
            case "aaron": return "portrait1"
            case "karina": return "portrait2"
            case "mike": return "portrait3"
            default: return "portrait4" // spare portrait if more reviews are added
            }
        }

        var body: some View {
            HStack(alignment: .top, spacing: 14) {
                // Avatar circle with portrait image
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))

                    Image(portraitName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                }
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(review.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)

                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.yellow)
                            }
                        }
                    }

                    Text(review.quote)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(18)
            .background(Color.black.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Review from \(review.name). Five star rating. \(review.quote)")
        }
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        OnboardingReviewsView()
    }
}
