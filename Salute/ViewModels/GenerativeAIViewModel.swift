//
//  GenerativeAIViewModel.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/11/24.
//

import Foundation
import GoogleGenerativeAI

class GenerativeAIViewModel: ObservableObject {
    // Access your API key from your on-demand resource .plist file (see "Set up your API key" above)
    let model = GenerativeModel(
        name: "gemini-1.5-flash", // "gemini-1.0-pro" "gemini-1.5-flash"
        apiKey: APIKey.default,
        generationConfig: GenerationConfig(
            temperature: 0.9,
            topP: 1,
            topK: 0,
            maxOutputTokens: 8192,
            responseMIMEType: "text/plain"
        ),
        systemInstruction: // •
            """
            You are a knowledgeable and helpful wine expert providing information for a mobile wine application. Your task is to generate concise, informative, and engaging content about wines, including descriptions, tasting notes, food pairings, and other relevant details.

            Please adhere to the following guidelines:

            • Accuracy: Prioritize accurate and factual information.
            • Brevity: Keep responses concise and easy to read on smaller screens. Use short sentences and paragraphs.
            • Mobile-Friendly Formatting:
                - Avoid bullet points or lists.
                - Use commas or the word "and" to separate items in a list.
                - Break down complex information into smaller, digestible sentences.
                - Avoid excessive jargon and technical terms.
            • Engaging Style: Maintain a friendly and conversational tone that appeals to wine enthusiasts of all levels.
            • Context Awareness: Tailor your response to the specific wine and the user's query.

            Please ensure that your responses are easily scannable and understandable for users on mobile devices.
            """
    )
    
    func generateWineAPIDescription(for wine: WineAPI, completion: @escaping (String?, Error?) -> Void) {
        let prompt = "Generate a small 1-3 sentence description about the wine \(wine.wine!) from the winery \(wine.winery!) from the location \(formatWineAPILocation(location: wine.location!))."
                                
        Task {
            do {
                let response = try await model.generateContent(prompt)
                
                guard var description = response.text else  {
                    completion(nil, NSError(domain: "GenerativeAIViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No generated text found"]))
                    return
                }
                
                while description.hasSuffix("\n") {
                    description.removeLast()
                }
                
                completion(description, nil)
            } catch {
                print("Something went wrong!\n\(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    func generateWineAPITastingNotes(for wine: WineAPI, wineType: String, completion: @escaping (String?, Error?) -> Void) {
        let prompt = "Generate detailed tasting notes for a \(wineType) wine named \(wine.wine!) produced by \(wine.winery!) in \(formatWineAPILocation(location: wine.location!)). In the first sentence, provide a captivating overview of the wine's overall character and most prominent flavor. Then, elaborate with 1 sentence describing the aroma, body, acidity, tannins (if applicable), and finish. Conclude with 1 sentence suggesting ideal food pairings to complement the wine."
                                
        Task {
            do {
                let response = try await model.generateContent(prompt)
                
                guard var tastingNotes = response.text else  {
                    completion(nil, NSError(domain: "GenerativeAIViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No generated text found"]))
                    return
                }
                
                while tastingNotes.hasSuffix("\n") {
                    tastingNotes.removeLast()
                }
                
                completion(tastingNotes, nil)
            } catch {
                print("Something went wrong!\n\(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    func generateWineBottleDescription(wineName: String, winery: String, location: String, completion: @escaping (String?, Error?) -> Void) {
        let prompt = "Generate a small 1-3 sentence description about the wine \(wineName) from the winery \(winery) from the location \(location)."
                                
        Task {
            do {
                let response = try await model.generateContent(prompt)
                
                guard var description = response.text else  {
                    completion(nil, NSError(domain: "GenerativeAIViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No generated text found"]))
                    return
                }
                
                while description.hasSuffix("\n") {
                    description.removeLast()
                }
                
                completion(description, nil)
            } catch {
                print("Something went wrong!\n\(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    func generateWineBottleTastingNotes(wineName: String, winery: String, location: String, wineType: String, completion: @escaping (String?, Error?) -> Void) {
        let prompt = "Generate detailed tasting notes for a \(wineType) wine named \(wineName) produced by \(winery) in \(location). In the first sentence, provide a captivating overview of the wine's overall character and most prominent flavor. Then, elaborate with 1 sentence describing the aroma, body, acidity, tannins (if applicable), and finish. Conclude with 1 sentence suggesting ideal food pairings to complement the wine."
                                
        Task {
            do {
                let response = try await model.generateContent(prompt)
                
                guard var tastingNotes = response.text else  {
                    completion(nil, NSError(domain: "GenerativeAIViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No generated text found"]))
                    return
                }
                
                while tastingNotes.hasSuffix("\n") {
                    tastingNotes.removeLast()
                }
                
                completion(tastingNotes, nil)
            } catch {
                print("Something went wrong!\n\(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    func formatWineAPILocation(location: String) -> String {
        let components = location.components(separatedBy: "\n·\n")
        if components.count == 2 {
            return "\(components[1]), \(components[0])"
        } else {
            return location
        }
    }
}
