//
//  ContentView.swift
//  FoundationModelsTrial
//
//  Created by Alumno on 13/11/25.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    @State private var pais: String = ""
    @State private var descripcion: String = ""
    var body: some View {
        VStack {
            
            TextField("Que pais te gustaria conocer?", text: $pais)
            
            Button("Obtener description") {
                task { await generateDescription()}
            }
        }
        .padding()
    }
    
    func generateDescription() async {
        guard !pais.isEmpty else { return }
        do {
            let model = try SystemLanguageModel.default
        }
    }
}

#Preview {
    ContentView()
}
