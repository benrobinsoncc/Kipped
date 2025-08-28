//
//  APIKeyInputView.swift
//  Kipped
//
//  Created by Assistant on 14/07/2025.
//

import SwiftUI

struct APIKeyInputView: View {
    @Binding var apiKey: String
    let accentColor: Color
    let selectedFont: FontOption
    // New configurable props
    var titleText: String = "OpenAI API Key"
    var helperText: String = "Enter your OpenAI API key to enable AI-powered memory summaries. Your key is stored locally and never shared."
    var docLinkTitle: String = "Get an API key from OpenAI"
    var docLinkURL: String = "https://platform.openai.com/api-keys"
    var placeholder: String = "sk-..."
    var storageKey: String = "openAIAPIKey"
    
    @Environment(\.presentationMode) var presentationMode
    @State private var tempAPIKey: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(titleText)
                        .appFont(selectedFont)
                        .font(.headline)
                    
                    Text(helperText)
                        .appFont(selectedFont)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    SecureField(placeholder, text: $tempAPIKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Link(docLinkTitle, destination: URL(string: docLinkURL)!)
                        .appFont(selectedFont)
                        .font(.caption)
                        .foregroundColor(accentColor)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.secondary)
                    
                    Button("Save") {
                        apiKey = tempAPIKey
                        // Update the service with the new key
                        UserDefaults.standard.set(tempAPIKey, forKey: storageKey)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(tempAPIKey.isEmpty)
                    .foregroundColor(tempAPIKey.isEmpty ? .secondary : accentColor)
                }
                .appFont(selectedFont)
                .padding()
            }
            .navigationTitle("API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.15))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary.opacity(0.7))
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                }
            }
        }
        .onAppear {
            tempAPIKey = apiKey
            isTextFieldFocused = true
        }
    }
}