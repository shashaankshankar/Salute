// In the Xcode Add Packages dialog, add this Swift package URL into the search bar:
// https://github.com/google-gemini/generative-ai-swift
//
// See the Getting Started guide for more information:
// https://ai.google.dev/gemini-api/docs/get-started/swift

// Add the following code to your Swift source code
import GoogleGenerativeAI

let config = GenerationConfig(
  temperature: 1,
  topP: 0.95,
  topK: 64,
  maxOutputTokens: 500,
  responseMIMEType: "text/plain"
)

// Don't check your API key into source control!
guard let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] else {
  fatalError("Add GEMINI_API_KEY as an Environment Variable in your app's scheme.")
}

let model = GenerativeModel(
  name: "gemini-1.5-flash",
  apiKey: apiKey,
  generationConfig: config,
  // safetySettings: Adjust safety settings
  // See https://ai.google.dev/gemini-api/docs/safety-settings
)

let chat = model.startChat(history: [
  ModelContent(
    role: "user",
    parts: [
      .text("Generate a small description about the wine Emporda 2012 from the winery Maselva.")
    ]
  ),
  ModelContent(
    role: "model",
    parts: [
      .text("## Empordà 2012 by Maselva: A taste of the Mediterranean sun\n\nThis vibrant red wine, crafted by the esteemed Maselva winery, showcases the bold character of the Empordà region. Made with a blend of Grenache, Carignan, and Syrah, it offers aromas of ripe black fruit, spice, and a hint of Mediterranean herbs. Expect a full-bodied palate with balanced tannins and a lingering finish that reflects the warm sunshine and rocky soils of its origin. Perfect for enjoying with hearty meals or simply savoring on its own. \n")
    ]
  )
])

Task {
  do {
    let message = "INSERT_INPUT_HERE"
    let response = try await chat.sendMessage(message)
    print(response.text ?? "No response received")
  } catch {
    print(error)
  }
}
