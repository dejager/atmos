//
//  ContentView.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            VStack {
                Text("The universe smiles upon you.")
                    .multilineTextAlignment(.center)
                    .font(Font.system(.title))
                    .fontWeight(.light)
                    .foregroundColor(.white)
            }
            .frame(width: 300, height: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(lineGradient,
                            lineWidth: 1))
            .makeItRainHere(cornerRadius: 18) // 👈 defines an area where the rain effect will appear
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // 👇 coordinates the rendering of the background into a metal texture which is blurred
            // and has a rain effect applied.
            AtmosphericEffect {
                Image("tofino")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            }

        )
        .ignoresSafeArea()
    }

    private var lineGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [.white.opacity(0.2), .black.opacity(0.3)]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
