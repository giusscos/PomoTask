//
//  PaywallContent.swift
//  TomaTask
//

import StoreKit
import SwiftUI

// MARK: - Pro catalogue

struct ProFeature: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let icon: String
    let subtitle: LocalizedStringResource
}

let proFeatures: [ProFeature] = [
    ProFeature(
        title: "Progressive Timer",
        icon: "dial.medium.fill",
        subtitle: "Blocks that grow with your flow"
    ),
    ProFeature(
        title: "Smart check-ins",
        icon: "bubble.left.and.text.bubble.right.fill",
        subtitle: "Go longer, shorten, or take a break"
    ),
    ProFeature(
        title: "Struggle escape",
        icon: "exclamationmark.bubble.fill",
        subtitle: "Cut time or rest — no guilt"
    ),
    ProFeature(
        title: "Focus statistics",
        icon: "chart.bar.fill",
        subtitle: "Streaks, week focus, tomato splash"
    ),
    ProFeature(
        title: "Themes",
        icon: "swatchpalette.fill",
        subtitle: "Solid colors and gradients"
    ),
    ProFeature(
        title: "App icons",
        icon: "app.badge.fill",
        subtitle: "Handcrafted tomato icons"
    ),
]

enum PaywallContext {
    case onboarding
    case general
    /// Opened after the free Progressive sessions ran out.
    case trialEnded
}

/// PomoTask look: tomato field, white rounded type, white capsule CTA with red text.
private enum PaywallStyle {
    static let background = OnboardingStyle.tomatoRed
    static let card = Color.white.opacity(0.12)
    static let selectedCard = Color.white.opacity(0.22)
    static let secondaryText = Color.white.opacity(0.75)
}

// MARK: - Paywall

struct PaywallView: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage(ProgressiveTrial.freeSessionsUsedKey) private var freeSessionsUsed = 0

    var context: PaywallContext = .general
    /// Onboarding passes its own completion; sheets fall back to `dismiss`.
    var onClose: (() -> Void)? = nil

    @State private var selectedProductID = Store.yearlyID
    @State private var didUnlock = false
    @State private var trialEligibleIDs: Set<String> = []
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    private var isSubscribed: Bool { !store.purchasedSubscriptions.isEmpty }

    private var freeSessionsLeft: Int {
        max(ProgressiveTrial.freeSessionLimit - freeSessionsUsed, 0)
    }

    var body: some View {
        ZStack {
            PaywallStyle.background.ignoresSafeArea()

            if didUnlock {
                ProWelcomeView { close() }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                paywallContent
                    .transition(.opacity)
            }
        }
        .fontDesign(.rounded)
        .preferredColorScheme(.dark)
        .onChange(of: isSubscribed) { _, newValue in
            guard newValue else { return }
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) { didUnlock = true }
        }
        .task(id: store.paywallProducts.map(\.id)) { await loadTrialEligibility() }
    }

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    private var selectedProduct: Product? {
        store.paywallProducts.first(where: { $0.id == selectedProductID }) ?? store.paywallProducts.first
    }

    private func hasEligibleTrial(_ product: Product) -> Bool {
        product.freeTrialPeriod != nil && trialEligibleIDs.contains(product.id)
    }

    private func loadTrialEligibility() async {
        var eligible: Set<String> = []
        for product in store.paywallProducts where product.freeTrialPeriod != nil {
            if await product.subscription?.isEligibleForIntroOffer == true {
                eligible.insert(product.id)
            }
        }
        trialEligibleIDs = eligible
    }

    private var paywallContent: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(y: -220)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    featureGrid
                    pricingSection
                    footer
                }
            }
            // Pinned so the purchase button is always visible without scrolling.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ctaButton
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    .background(
                        LinearGradient(
                            colors: [PaywallStyle.background.opacity(0), PaywallStyle.background],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 80, height: 80)
                Image(systemName: "dial.medium.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.top, 36)
            .padding(.bottom, 4)
            .onboardingPop(delay: 0.05)

            Text(verbatim: "PomoTask Pro")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .onboardingPop(delay: 0.12)

            Group {
                if context == .trialEnded {
                    Text("You’ve used your \(ProgressiveTrial.freeSessionLimit) free Progressive sessions. Unlock Pro to keep growing your focus.")
                } else {
                    Text("Find your focus length — then grow it with adaptive blocks, check-ins, and clear stats.")
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(PaywallStyle.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .onboardingPop(delay: 0.18)
        }
        .padding(.bottom, 22)
    }

    // MARK: - Features

    // Two-column grid keeps all features and the plans above the fold on most phones.
    private var featureGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(Array(proFeatures.enumerated()), id: \.element.id) { index, feature in
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(.white.opacity(0.18))
                            .frame(width: 34, height: 34)
                        Image(systemName: feature.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(feature.subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(PaywallStyle.secondaryText)
                            .lineLimit(2, reservesSpace: true)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(PaywallStyle.card, in: RoundedRectangle(cornerRadius: 16))
                .onboardingPop(delay: 0.24 + Double(index) * 0.05)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Pricing

    @ViewBuilder
    private var pricingSection: some View {
        if store.paywallProducts.isEmpty {
            placeholderPricing
        } else {
            VStack(spacing: 10) {
                ForEach(store.paywallProducts) { product in
                    productCard(product)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func planName(for product: Product) -> String {
        switch product.id {
        case Store.yearlyID: String(localized: "Yearly")
        case Store.weeklyID: String(localized: "Weekly")
        default: product.displayName
        }
    }

    private func productCard(_ product: Product) -> some View {
        let isSelected = selectedProductID == product.id
        let isYearly = product.id == Store.yearlyID

        return Button {
            withAnimation(.spring(duration: 0.2, bounce: 0.1)) {
                selectedProductID = product.id
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(verbatim: planName(for: product))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        if hasEligibleTrial(product), let trial = product.freeTrialText {
                            badge(String(localized: "\(trial) FREE").uppercased(), filled: true)
                        } else if isYearly {
                            badge(String(localized: "BEST VALUE"), filled: false)
                        }
                    }
                    Text(verbatim: planSubtitle(for: product))
                        .font(.system(size: 12, weight: isYearly && savingsPercent(for: product) != nil ? .bold : .medium))
                        .foregroundStyle(PaywallStyle.secondaryText)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? .white : .white.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? PaywallStyle.selectedCard : PaywallStyle.card)
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(.white.opacity(0.8), lineWidth: 1.5)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedProductID)
    }

    private func badge(_ text: String, filled: Bool) -> some View {
        Text(verbatim: text)
            .font(.system(size: 9, weight: .heavy).width(.expanded))
            .foregroundStyle(filled ? PaywallStyle.background : .white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(filled ? .white : .white.opacity(0.25), in: Capsule())
    }

    /// Yearly vs. 52 weekly payments, rounded down so we never overstate the saving.
    private func savingsPercent(for yearly: Product) -> Int? {
        guard yearly.id == Store.yearlyID,
              let weekly = store.paywallProducts.first(where: { $0.id == Store.weeklyID }) else { return nil }
        let fullYear = NSDecimalNumber(decimal: weekly.price * 52).doubleValue
        let yearlyPrice = NSDecimalNumber(decimal: yearly.price).doubleValue
        guard fullYear > 0, yearlyPrice < fullYear else { return nil }
        let percent = Int(((fullYear - yearlyPrice) / fullYear * 100).rounded(.down))
        return percent > 0 ? percent : nil
    }

    private func planSubtitle(for product: Product) -> String {
        switch product.id {
        case Store.yearlyID:
            if let percent = savingsPercent(for: product) {
                return String(localized: "\(product.weeklyEquivalentText)/week · save \(percent)%")
            }
            return String(localized: "Billed yearly")
        default:
            return String(localized: "Billed weekly")
        }
    }

    private var placeholderPricing: some View {
        VStack(spacing: 10) {
            ForEach(["Yearly", "Weekly"], id: \.self) { name in
                HStack {
                    Text(LocalizedStringKey(name))
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text(verbatim: "–")
                }
                .padding(14)
                .background(PaywallStyle.card, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .redacted(reason: .placeholder)
    }

    // MARK: - CTA

    private var ctaTitle: String {
        if let product = selectedProduct, hasEligibleTrial(product), let trial = product.freeTrialText {
            return String(localized: "Try \(trial) free")
        }
        return String(localized: "Unlock Pro")
    }

    /// What the user will be charged, shown right under the button (required for free trials).
    private var ctaDisclosure: String? {
        guard let product = selectedProduct else { return nil }
        if hasEligibleTrial(product), let trial = product.freeTrialText {
            return String(localized: "\(trial) free, then \(product.pricePerPeriodText). Cancel anytime.")
        }
        return String(localized: "\(product.pricePerPeriodText). Cancel anytime.")
    }

    private var ctaButton: some View {
        VStack(spacing: 8) {
            purchaseButton
            if let ctaDisclosure {
                Text(verbatim: ctaDisclosure)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PaywallStyle.secondaryText)
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: ctaDisclosure)
            }
        }
        .padding(.horizontal, 24)
    }

    private var purchaseButton: some View {
        Button {
            guard let product = selectedProduct else { return }
            Task { await purchase(product) }
        } label: {
            ZStack {
                if isPurchasing {
                    ProgressView().tint(PaywallStyle.background)
                } else {
                    Text(verbatim: ctaTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(PaywallStyle.background)
                        .contentTransition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(.white, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .disabled(isPurchasing || store.paywallProducts.isEmpty)
    }

    @MainActor
    private func purchase(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        do {
            if try await store.purchase(product) != nil {
                store.grantProduct(product)
            }
        } catch {
            purchaseError = String(localized: "Purchase failed. Please try again.")
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 12) {
            if let purchaseError {
                Text(verbatim: purchaseError)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button {
                Task { await store.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Button(action: close) {
                Group {
                    if freeSessionsLeft > 0 {
                        Text("Continue with \(freeSessionsLeft) free sessions")
                    } else {
                        Text("Not now")
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .underline()
            }

            Text("Subscriptions auto-renew unless cancelled. Manage in Settings.")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: LegalURLs.privacyPolicy)
                Text(verbatim: "·")
                Link("Terms of Use", destination: LegalURLs.termsOfUse)
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}

// MARK: - Welcome to Pro

private struct ProWelcomeView: View {
    let onContinue: () -> Void

    @State private var appeared = false
    @State private var burst = false

    private let confettiColors: [Color] = [
        .white,
        Color(red: 1.0, green: 0.85, blue: 0.3),
        Color(red: 0.3, green: 0.75, blue: 0.35),
        Color(red: 1.0, green: 0.6, blue: 0.45),
        Color(red: 1.0, green: 0.8, blue: 0.8),
    ]

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(y: -120)

            confetti

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(.white)
                    Image(systemName: "dial.medium.fill")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(PaywallStyle.background)
                }
                .frame(width: 150, height: 150)
                .shadow(color: .black.opacity(0.2), radius: 30, y: 10)
                .rotationEffect(.degrees(appeared ? -4 : 8))
                .offset(y: appeared ? 0 : -60)
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .padding(.bottom, 40)

                Text("Welcome to Pro")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                Text("Progressive, stats, themes, and icons are now yours. Thanks for supporting PomoTask.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(PaywallStyle.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 12)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                Button(action: onContinue) {
                    Text("Start Focusing")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(PaywallStyle.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
                .opacity(appeared ? 1 : 0)
            }
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            withAnimation(.spring(duration: 0.8, bounce: 0.35)) { appeared = true }
            withAnimation(.easeOut(duration: 1.6)) { burst = true }
        }
    }

    private var confetti: some View {
        ZStack {
            ForEach(0..<28, id: \.self) { i in
                let angle = Double(i) / 28.0 * 2 * .pi
                let distance: CGFloat = 150 + CGFloat((i * 37) % 90)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(confettiColors[i % confettiColors.count])
                    .frame(width: 6, height: 11)
                    .rotationEffect(.degrees(burst ? Double(i * 47) : 0))
                    .offset(
                        x: burst ? cos(angle) * distance : 0,
                        y: burst ? sin(angle) * distance + 80 : 0
                    )
                    .opacity(burst ? 0 : 1)
            }
        }
        .offset(y: -120)
        .allowsHitTesting(false)
    }
}

// MARK: - Product formatting

extension Product {
    /// The free-trial part of the introductory offer, if the offer is a free trial.
    var freeTrialPeriod: Product.SubscriptionPeriod? {
        guard let offer = subscription?.introductoryOffer, offer.paymentMode == .freeTrial else { return nil }
        return offer.period
    }

    /// "7 days", "1 month" — used in trial badges and the post-trial disclosure.
    var freeTrialText: String? {
        guard let period = freeTrialPeriod else { return nil }
        switch period.unit {
        case .day, .week:
            let days = period.unit == .week ? period.value * 7 : period.value
            return days == 1 ? String(localized: "1 day") : String(localized: "\(days) days")
        case .month:
            return period.value == 1 ? String(localized: "1 month") : String(localized: "\(period.value) months")
        case .year:
            return period.value == 1 ? String(localized: "1 year") : String(localized: "\(period.value) years")
        @unknown default:
            return nil
        }
    }

    /// "$49.99/year", "$4.99/week".
    var pricePerPeriodText: String {
        switch subscription?.subscriptionPeriod.unit {
        case .year: String(localized: "\(displayPrice)/year")
        case .month: String(localized: "\(displayPrice)/month")
        case .week: String(localized: "\(displayPrice)/week")
        default: displayPrice
        }
    }

    /// Price divided by 52, formatted in the storefront currency. Only meaningful for yearly plans.
    var weeklyEquivalentText: String {
        (price / 52).formatted(priceFormatStyle)
    }
}

#Preview {
    PaywallView(context: .onboarding)
        .environment(Store())
}
