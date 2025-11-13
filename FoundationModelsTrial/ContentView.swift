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
        VStack(spacing: 16) {
            Text("🌍 Generador de Descripciones de Países")
                .font(.title2)
                .bold()

            TextField("Escribe un país...", text: $country)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button(action: {
                Task { await generateCountryDescription() }
            }) {
                Text("Generar descripción")
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
            // 1) Obtener el modelo del sistema
            let model = SystemLanguageModel.default

            // 2) Verificar disponibilidad
            guard model.availability == .available else {
                descriptionText = "El modelo de lenguaje no está disponible en este dispositivo."
                isLoading = false
                return
            }

            // 3) Crear una sesión. Usamos el inicializador con instrucciones (forma recomendada).
            //    Puedes pasar un texto guía que sirva como "system prompt".
            let instructions = """
            Eres un asistente conciso y amigable. Responde en español.
            """
            let session = LanguageModelSession(instructions: instructions)

            // 4) Prompt para la generación
            let prompt = """
            Describe el país \(country) en unas 4 frases.
            Luego menciona tres lugares turísticos populares que todo visitante debería conocer,
            separados por comas y con una frase corta para cada uno.
            """

            // 5) Pedir respuesta al modelo
            let response = try await session.respond(to: prompt)

            // 6) Obtener texto de la respuesta (la mayoría de ejemplos usan `content`)
            //    Si tu versión del SDK usa otra propiedad, cámbiala (por ejemplo `.text`).
            descriptionText = response.content

        } catch {
            // Muestra el mensaje de error para depuración
            descriptionText = "Error: \(error.localizedDescription)"
            print("FoundationModels error:", error)
        }

        isLoading = false
    }
}

#Preview {
    ContentView()
}
