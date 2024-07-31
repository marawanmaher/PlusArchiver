import SwiftUI
import Zip

struct ContentView: View {
    @State private var selectedFile: URL?
    @State private var destinationFolder: URL?
    @State private var showFilePicker = false
    @State private var showFolderPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var unarchivedFiles: [String] = []

    var body: some View {
        HStack {
            // History View on the left
            VStack(alignment: .leading, spacing: 10) {
                Text("Unarchived Files")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
                
                if unarchivedFiles.isEmpty {
                    Text("No files unarchived yet")
                        .foregroundColor(.gray)
                } else {
                    List(unarchivedFiles, id: \.self) { file in
                        Text(file)
                    }
                    .frame(maxHeight: 300)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .frame(width: 250) // Adjusted width for better alignment
            
            Spacer()

            // Main Content View
            VStack(spacing: 20) {
                Text("Plus Archiver")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let selectedFile = selectedFile {
                    Text("Selected File: \(selectedFile.lastPathComponent)")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Button(action: {
                        showFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc")
                            Text("Select File to Unarchive")
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                    .buttonStyle(DefaultButtonStyle())
                    .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.archive]) { result in
                        switch result {
                        case .success(let url):
                            if FileManager.default.isReadableFile(atPath: url.path) {
                                selectedFile = url
                            } else {
                                alertMessage = "File is not readable."
                                showAlert = true
                            }
                        case .failure(let error):
                            alertMessage = "Failed to select file: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }

                if let destinationFolder = destinationFolder {
                    Text("Destination Folder: \(destinationFolder.lastPathComponent)")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Button(action: {
                        showFolderPicker = true
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text("Select Destination Folder")
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                    .buttonStyle(DefaultButtonStyle())
                    .fileImporter(isPresented: $showFolderPicker, allowedContentTypes: [.folder]) { result in
                        switch result {
                        case .success(let url):
                            if FileManager.default.isWritableFile(atPath: url.path) {
                                destinationFolder = url
                            } else {
                                alertMessage = "Folder is not writable."
                                showAlert = true
                            }
                        case .failure(let error):
                            alertMessage = "Failed to select folder: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }

                if selectedFile != nil && destinationFolder != nil {
                    Button(action: {
                        do {
                            alertMessage = "Unarchiving file: \(selectedFile!.path) to destination: \(destinationFolder!.path)"
                            showAlert = true
                            try Zip.unzipFile(selectedFile!, destination: destinationFolder!, overwrite: true, password: nil)
                            alertMessage = "File successfully unarchived!"
                            if let selectedFile = selectedFile {
                                unarchivedFiles.append(selectedFile.lastPathComponent)
                            }
                        } catch {
                            alertMessage = "Failed to unarchive file: \(error.localizedDescription)"
                        }
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Unarchive")
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                    .buttonStyle(DefaultButtonStyle())
                }

                if selectedFile != nil || destinationFolder != nil {
                    Button(action: {
                        selectedFile = nil
                        destinationFolder = nil
                        alertMessage = "Operation reset."
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Start Over")
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                    .buttonStyle(DefaultButtonStyle())
                }

                Spacer()

            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Plus Archiver"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .frame(maxWidth: 400)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
// made with love by plusdata.io
