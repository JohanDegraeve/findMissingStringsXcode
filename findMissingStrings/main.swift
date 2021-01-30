import Foundation

// MARK: - private properties

/// header to add when extending a strings file
private let headerInfo = "\n" +
                         "\n" +
                         "/////////////////////////////////////////////////////////////////////////////////////////////\n" +
                         "/////   Translation needed - remove this header after translation                       /////\n" +
                         "/////////////////////////////////////////////////////////////////////////////////////////////\n"

/// argument name for base folder - example xdripswift/xdrip/Storyboards, means without specifying a language folder like en.lproj
private let argumentNameBaseFolder = "-basefolder"

/// argument name for subfolder that has the base language, eg en.lproj, which is also the default
private let argumentNameBaseLanguage = "-baseLanguage"

/// - list of subfolders with other languages to check, comma seperated list eg "de.lproj, fr.lproj, pt-BR.lproj"
private let argumentListOfLanguageFolders = "-listOfLanguageFolders"

/// where to find the swift files, that contain the NSLocalizedString localed string definitions, used to find the comments
private let argumentSwiftFilesFolder = "-swiftFilesFolder"

/// list of arguments, initalized with default values
var arguments: [String : String] = [argumentNameBaseFolder: "",
                 argumentNameBaseLanguage : "en.lproj",
                 argumentListOfLanguageFolders : "",
                 argumentSwiftFilesFolder : ""]

// MARK: - main

/// read arguments from command line and store in arguments
read(commandLineArguments: CommandLine.arguments, storeIn: &arguments)

// get all filenames in the folder baseFolder/baseLanguage
if let baseFolder = arguments[argumentNameBaseFolder], let baseLanguage = arguments[argumentNameBaseLanguage] {
    
    /// comments found in swift files
    var comments = [String: String]()
    
    // read comments from swiftFilesFolder, or at least try to
    if let swiftFilesFolder = arguments[argumentSwiftFilesFolder], swiftFilesFolder.count > 0 {
        
        comments = getAllComments(textsPath: swiftFilesFolder)
        
    }

    /// path that has the base language files
    let baseLanguageFilesPath = baseFolder + "/" + baseLanguage
    
    /// list of string files in the base language
    let stringFilesInBaseLanguage = readFiles(atPath: baseLanguageFilesPath)
    
    /// list of language folders in [String]
    guard let languageFolders = arguments[argumentListOfLanguageFolders]?.split(separator: ",").map({String($0)}) else {fatalError("failed to create list of language folders, check the argument value " + argumentListOfLanguageFolders)}

    // iterate through files
    for stringFile in stringFilesInBaseLanguage {
        
        /// all strings in the stringFile being processed , in base language
        let baseLanguageStrings = readStrings(fromFile: stringFile, atPath: baseLanguageFilesPath, createIfNotExisting: false)
        
        // iterate through language folders
        for languageFolder in languageFolders {
            
            /// full path where language string files are stored
            let languageFilesPath = baseFolder + "/" + languageFolder
            
            /// get strings file in languageFolder, create the file if it doesn't exist
            let languageStrings = readStrings(fromFile: stringFile, atPath: languageFilesPath, createIfNotExisting: true)
            
            /// get missing strings in language specific file
            let missingStrings = getStrings(thatAreIn: baseLanguageStrings, butNotIn: languageStrings)
            
            // if there are missing strings
            if missingStrings.count > 0 {
                
                // create outputstream
                if let outputStream = OutputStream(toFileAtPath: languageFilesPath + "/" + stringFile, append: true) {
                    
                    // open the outputStream
                    outputStream.open()
                    
                    // write headerinfo to file
                    writeToFile(outputStream: outputStream, stringToWrite: headerInfo)
                    
                    // add missing strings
                    for (key, value) in missingStrings {
                        
                        var comment = comments[key]
                        if comment == nil {comment = ""}
                        comment = "/// " + comment!
                        
                        // write string to file
                        writeToFile(outputStream: outputStream, stringToWrite: "\n" + comment! + "\n\"" + key + "\" = \"" + value + "\";\n")
                        
                    }
                    
                    // close the outputstream
                    outputStream.close()
                    
                }
                
                
                
            }
            
        }
        
    }

}

// MARK: - private functions

/// reads command line arguments
/// - parameters:
///     - commandLineArguments : list of arguments used in launching
///     - storeIn : must be preinitialized list of argumentname, argument value pairs
private func read(commandLineArguments : [String], storeIn: inout [String : String]) {
    
    /// - if commandLineArguments is not uneven, then exit
    /// - should be uneven because script name is always included
    if commandLineArguments.count % 2 == 0 {
        fatalError("arguments are list of argument name and argument value. Argument name starts with '-'. Argument names and argument values are seperated by sapce. There seems to be something wrong in your list of arguments")
    }
    
    // iterate through arguments
    for (index, _) in commandLineArguments.enumerated() {
        
        // if index is not uneven then commandLineArguments[index] is not an argument name
        if index%2 == 0 {continue}
        
        // get next argument name
        let argumentName = commandLineArguments[index]
        
        // argument name should start with -
        if !argumentName.starts(with: "-") {
            fatalError("every argument name should start with '-'. Check argument name " + argumentName)
        }
        
        // get argument value
        let argumentValue = commandLineArguments[index + 1]
        
        // check if argument name is a valid one
        if storeIn.index(forKey: argumentName) != nil {
            
            storeIn.updateValue(argumentValue, forKey: argumentName)
            
        } else {
            
            fatalError("invalid argument name : " + argumentName + ", allowed argument names must be intialized in variable arguments")
            
        }
    }
    
}

/// reads string file line by line and stores results in pair of key and value
/// - parameters:
///     - fromFile : filename of the file from which strings will be read
///     - atPath : the path where the file is (or should be) located
///     - createIfNotExisting : if the file doesn't exist, should it be created ?
/// - returns:
///     - array of key/value pairs, retrieved from string files
///     - if file does not exist (or did not exist before), then return value is an empty array
private func readStrings(fromFile: String, atPath: String, createIfNotExisting: Bool) -> [String : String] {
    
    // if atPath does not exist, then crash
    var isDirectory: ObjCBool = true
    guard FileManager.default.fileExists(atPath: atPath, isDirectory:&isDirectory) else {
        fatalError("path " + atPath + " does not exist")
    }
    
    // path + filename
    let pathAndFileName = atPath + "/" + fromFile
    
    // if the file does not exist return empty array
    // but first if createIfNotExisting is true, create the file
    isDirectory = false
    if !FileManager.default.fileExists(atPath: pathAndFileName, isDirectory: &isDirectory) {
        
        if createIfNotExisting {
            
            FileManager.default.createFile(atPath: pathAndFileName, contents: nil, attributes: nil)
            
        }
        
        return [String: String]()
        
    }
    
    do {
        
        // initialise returnValue
        var returnValue = [String: String]()
        
        // get fileContents, as one string
        let fileContents = try String(contentsOf: URL(fileURLWithPath: pathAndFileName), encoding: .utf8)
        
        // parse filecontents
        let parsedText = getParsedText(text: fileContents)
        
        // stored parsedText in dictionary
        for pair in parsedText {
            
            returnValue[pair.key] = pair.text
            
        }
        
        return returnValue
        
    } catch {
        
        fatalError("failed to read file " + fromFile + ", at path " + atPath)
        
    }
    
}

/// reads files found in atPath
private func readFiles(atPath: String) -> [String] {
    
        do {
            
            return try FileManager.default.contentsOfDirectory(atPath: atPath)
            
        } catch {
            
            fatalError("failed to read files in " + atPath)
            
        }
    
}

// source https://stackoverflow.com/questions/39705576/trying-to-parse-a-localizable-string-file-for-a-small-project-in-swift-on-macos
private func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        guard let result = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: nsString.length)) else {
            return [] // pattern does not match the string
        }
        return (1 ..< result.numberOfRanges).map {
            nsString.substring(with: result.range(at: $0))
        }
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

/// process text line by line, returns array of tuples, being key and text as read from strings file
///
/// source https://stackoverflow.com/questions/39705576/trying-to-parse-a-localizable-string-file-for-a-small-project-in-swift-on-macos
private func getParsedText(text: String) -> [(key: String, text: String)] {
    var dict: [(key: String, text: String)] = []
    let exp = "\"(.*)\"[ ]*=[ ]*\"(.*)\";"
    
    for line in text.components(separatedBy: "\n") {
        let match = matches(for: exp, in: line)
        if match.count == 2 {
            dict.append((key: match[0], text: match[1]))
        }
    }
    return dict
}

/// - parameters:
///     - textsPath : foldername where all swift files with the string definitions can be found, the NSLocalizedString things
private func getAllComments(textsPath: String) -> Dictionary<String, String> {
    
    // if textsPath does not exist, then crash
    var isDirectory: ObjCBool = true
    guard FileManager.default.fileExists(atPath: textsPath, isDirectory:&isDirectory) else {
        fatalError("path " + textsPath + " does not exist")
    }
    
    /// all swift files
    let swiftFiles = readFiles(atPath: textsPath)

    /// returnValue will have all keys and coments found in swift files
    var returnValue = [String: String]()

    // iterate through the files
    for swiftFile in swiftFiles {
     
        // path + filename
        let pathAndFileName = textsPath + "/" + swiftFile
        
        do {
            
            // get fileContents, as one string
            let fileContents = try String(contentsOf: URL(fileURLWithPath: pathAndFileName), encoding: .utf8)
            
            // parse filecontents
            let parsedText = getParsedComments(text: fileContents)
            
            // stored parsedText in dictionary
            for pair in parsedText {
                returnValue[pair.key] = pair.text
            }
            
        } catch {
            
            fatalError("failed to read file " + swiftFile + ", at path " + textsPath)
            
        }

    }
    
    // incase there's no swiftfiles found
    return returnValue
    
}

private func getParsedComments(text: String) -> [(key: String, text: String)] {
    
    var dict: [(key: String, text: String)] = []
    
    // looking in swift files for the comments, example of a line :
    /* in this example we're interested in the key 'confirmdeletionalert' and the comment 'when trying to delete an alert, user needs to confirm first, this is the message'
     return NSLocalizedString("confirmdeletionalert", tableName: filename, bundle: Bundle.main, value: "Delete Alarm?", comment: "when trying to delete an alert, user needs to confirm first, this is the message")
     */
    let exp = "(.*)\"(.*)\"(.*)\"(.*)\"(.*)\"(.*)\""
    
    for line in text.components(separatedBy: "\n") {
        let match = matches(for: exp, in: line)
        if match.count >= 6 {
            dict.append((key: match[1], text: match[5]))
        }
    }
    return dict
}

/// returns dictionary with key/value pair that is in thatAreIn but not in thatAreIn
private func getStrings(thatAreIn: Dictionary<String, String>, butNotIn: Dictionary<String, String>) -> Dictionary<String, String> {
    
    // initialize returnValue equal to initial list being thatAreIn
    var returnValue = thatAreIn
    
    for (key, _) in butNotIn {
        
        returnValue.removeValue(forKey: key)
        
    }
    
    return returnValue
    
}

/// helper function to write string to outputstream
private func writeToFile(outputStream: OutputStream, stringToWrite: String) {
    
    // convert headerInfo to array of UInt8
    let stringToWriteAsUInt8 = [UInt8](stringToWrite.utf8)
    
    outputStream.write(stringToWriteAsUInt8, maxLength: stringToWriteAsUInt8.count)
    
}
