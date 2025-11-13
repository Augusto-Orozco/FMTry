//
//  ContentView.swift
//  FoundationModelsTrial
//
//  Created by Alumno on 13/11/25.
//

import SwiftUI
import FoundationModels

@MainActor
struct ContentView: View {
    @State private var country = ""
    @State private var descriptionText = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Acerca de que pais te gustaria conocer?")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            TextField("Escribe aqui tu eleccion...", text: $country)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button(action: {
                Task { await generateCountryDescription() }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundStyle(.tint)
            }
            .buttonStyle(.borderedProminent)
            .disabled(country.isEmpty || isLoading)

            if isLoading {
                ProgressView("Generando...")
                    .padding()
            } else {
                ScrollView {
                    Text(descriptionText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
    }

    func generateCountryDescription() async {
        guard !country.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        descriptionText = ""

        do {
            let model = SystemLanguageModel.default

            guard model.availability == .available else {
                descriptionText = "El modelo de lenguaje no está disponible en este dispositivo."
                isLoading = false
                return
            }

            let instructions = """
            Eres un asistente conciso y amigable. Responde en español.
            """
            let session = LanguageModelSession(instructions: instructions)
            
            let prompt = """
            Describe el país \(country) en unas 4 frases.
            Luego menciona tres lugares turísticos populares que todo visitante debería conocer,
            separados por comas y con una frase corta para cada uno.
            """
            
            let response = try await session.respond(to: prompt)

            descriptionText = response.content

        } catch {
            descriptionText = "Error: \(error.localizedDescription)"
            print("FoundationModels error:", error)
        }

        isLoading = false
    }
}

#Preview {
    ContentView()
}
