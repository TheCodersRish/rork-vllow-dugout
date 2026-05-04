import SwiftUI

struct MealQuestionnaireView: View {
    @Binding var profile: MealProfile
    var onSave: (MealProfile) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var draft: MealProfile
    @State private var allergyText: String = ""
    @State private var dislikeText: String = ""
    @State private var calorieText: String = ""

    init(profile: Binding<MealProfile>, onSave: @escaping (MealProfile) -> Void) {
        self._profile = profile
        self.onSave = onSave
        self._draft = State(initialValue: profile.wrappedValue)
        self._allergyText = State(initialValue: profile.wrappedValue.allergies.joined(separator: ", "))
        self._dislikeText = State(initialValue: profile.wrappedValue.dislikes.joined(separator: ", "))
        self._calorieText = State(initialValue: profile.wrappedValue.calorieTarget.map { String($0) } ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    intro

                    section("ABOUT YOU") {
                        stepperRow(label: "Age", value: $draft.age, range: 12...80, suffix: "yrs")
                        sexRow
                        stepperRow(label: "Height", value: $draft.heightCm, range: 130...220, suffix: "cm")
                        stepperRow(label: "Weight", value: $draft.weightKg, range: 35...160, suffix: "kg")
                    }

                    section("TRAINING") {
                        activityPicker
                        stepperRow(label: "Training hours / week", value: $draft.trainingHoursPerWeek, range: 0...40, suffix: "hrs")
                    }

                    section("DIETARY RESTRICTIONS") {
                        textRow(label: "Allergies (comma separated)", text: $allergyText, placeholder: "peanuts, shellfish")
                        textRow(label: "Foods you dislike", text: $dislikeText, placeholder: "mushrooms, olives")
                    }

                    section("OPTIONAL") {
                        textRow(label: "Calorie target (kcal)", text: $calorieText, placeholder: "2400", keyboard: .numberPad)
                        textRow(label: "Notes for the AI chef", text: $draft.notes, placeholder: "Loves Indian flavors, low spice...")
                    }

                    saveButton
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .background(AppTheme.darkBg)
            .scrollIndicators(.hidden)
            .navigationTitle("Meal Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tell us about you")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(AppTheme.textPrimary)
            Text("A few quick questions so the AI chef can craft a meal plan tuned to your body, training and tastes.")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(AppTheme.neonGreen)
            VStack(spacing: 10) {
                content()
            }
            .padding(14)
            .background(AppTheme.cardSurface)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5)
            )
        }
    }

    private func stepperRow(label: String, value: Binding<Int>, range: ClosedRange<Int>, suffix: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Text("\(value.wrappedValue) \(suffix)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.neonGreen)
                .contentTransition(.numericText())
            Stepper("", value: value, in: range)
                .labelsHidden()
                .tint(AppTheme.neonGreen)
        }
    }

    private var sexRow: some View {
        HStack {
            Text("Sex")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Picker("", selection: $draft.sex) {
                ForEach(Sex.allCases, id: \.self) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)
        }
    }

    private var activityPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity level")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Button {
                            withAnimation(.spring(response: 0.3)) { draft.activityLevel = level }
                        } label: {
                            Text(level.rawValue)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(draft.activityLevel == level ? .black : AppTheme.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(draft.activityLevel == level ? AppTheme.neonGreen : AppTheme.cardSurfaceLight)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 0)
            Text(draft.activityLevel.description)
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.textTertiary)
        }
    }

    private func textRow(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(12)
                .background(AppTheme.cardSurfaceLight)
                .clipShape(.rect(cornerRadius: 10))
                .tint(AppTheme.neonGreen)
        }
    }

    private var saveButton: some View {
        Button {
            var saved = draft
            saved.allergies = parseList(allergyText)
            saved.dislikes = parseList(dislikeText)
            saved.calorieTarget = Int(calorieText.trimmingCharacters(in: .whitespaces))
            onSave(saved)
            dismiss()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("SAVE & GENERATE PLAN")
                    .tracking(1.5)
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.neonGreen)
            .clipShape(.rect(cornerRadius: 16))
        }
        .sensoryFeedback(.success, trigger: draft.age)
    }

    private func parseList(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
