import SwiftUI

struct ContactSupportView: View {
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false

    private let topics = ["General", "Bug Report", "Feature Request", "Subscription", "Export Issue", "Other"]

    var body: some View {
        Form {
            Section {
                Picker("Topic", selection: $topic) {
                    ForEach(topics, id: \.self) { Text($0) }
                }

                TextField("Name (optional)", text: $name)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            } header: {
                Text("Message")
            }

            Section {
                Button {
                    submitFeedback()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(email.isEmpty || message.isEmpty || isSubmitting)
            }
        }
        .navigationTitle("Contact Support")
        .alert("Thank you!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your message has been sent. We will get back to you soon.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text("Failed to send message. Please try again later.")
        }
    }

    @Environment(\.dismiss) private var dismiss

    private func submitFeedback() {
        isSubmitting = true

        guard let backendURL = URL(string: "https://feedback-board.iocompile67692.workers.dev") else {
            isSubmitting = false
            showError = true
            return
        }

        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "topic": topic,
            "name": name,
            "email": email,
            "message": message,
            "app": "SheetSweep"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil {
                    showSuccess = true
                } else {
                    showError = true
                }
            }
        }.resume()
    }
}
