//
//  Copyright 2024 Roman Likhachev
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

class FileRepositoryImpl: FileRepository {
        
    func saveTextToLocalStorage(fileName: String, fileContents: String) async throws -> String? {
        // Miragte to full async
        try await Task.detached(priority: .background) {
            do {
                let documentsDirectory = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                let isAccessing = fileURL.startAccessingSecurityScopedResource()
                
                if !isAccessing {
                    throw FileError.accessingSecurityScopedError
                }
                
                try fileContents.write(to: fileURL, atomically: true, encoding: .utf8)
                
                fileURL.stopAccessingSecurityScopedResource()
                
                return fileURL.absoluteString
            } catch {
                if let fileError = error as? FileError {
                    throw error
                } else {
                    throw FileError.saveError
                }
            }
        }.value
    }
    
    func readTextFromFile(fileName: String) async throws -> String {
        // Miragte to full async
        try await Task.detached(priority: .background) {
            guard let fileURL = URL(string: fileName) else {
                throw FileError.invalidFileUrl
            }
            
            do {
                let fileContents = try String(
                    contentsOf: fileURL,
                    encoding: .utf8
                )
                return fileContents
            } catch {
                throw FileError.readError
            }
        }.value
    }
    
    func getFileName(uri: String) throws -> String {
        guard let url = URL(string: uri) else {
            throw FileError.invalidFileUrl
        }
        
        return url.lastPathComponent
    }
}
