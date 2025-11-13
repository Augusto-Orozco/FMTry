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
            Text("🌍 Generador de Descripción de Países")
                .font(.title2)
                .bold()

            TextField("Escribe un país...", text: $country)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Generar descripción") {
                Task { await generateCountryDescription() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(country.isEmpty || isLoading)

            if isLoading {
                ProgressView("Generando...")
            } else {
                ScrollView {
                    Text(descriptionText)
                        .padding()
                }
            }
        }
        .padding()
    }

    func generateCountryDescription() async {
        guard !country.isEmpty else { return }
        isLoading = true
        descriptionText = ""

        do {
            // 1️⃣ Obtiene el modelo del sistema
            let model = SystemLanguageModel.default

            // 2️⃣ Verifica disponibilidad
            guard model.availability == .available else {
                descriptionText = "El modelo de lenguaje no está disponible en este dispositivo."
                isLoading = false
                return
            }

            // 3️⃣ Crea una sesión de generación de texto
            let session = try LanguageModelSession(configuration: .init(model: model))

            // 4️⃣ Define las instrucciones / prompt
            let prompt = """
            Describe el país \(country) en unas 4 frases.
            Luego menciona tres lugares turísticos populares que todo visitante debería conocer.
            """

            // 5️⃣ Envía el prompt y espera respuesta
            let output = try await session.respond(to: prompt)

            // 6️⃣ Actualiza la UI
            descriptionText = output.text

        } catch {
            descriptionText = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

#Preview {
    ContentView()
}
