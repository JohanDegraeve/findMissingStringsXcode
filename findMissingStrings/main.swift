import Foundation

// MARK: - private properties

/// argument name for base folder - example xdripswift/xdrip/Storyboards, means without specifying a language folder like en.lproj
private let argumentNameBaseFolder = "basefolder"

/// argument name for subfolder that has the base language, eg en.lproj, which is also the default
private let argumentNameBaseLanguage = "baseLanguage"

/// - list of subfolders with other languages to check, comma seperated list eg "de.lproj, fr.lproj, pt-BR.lproj"
private let argumentListOfLanguageFolders = "listOfLanguageFolders"

/// list of arguments, initalized with default values
var arguments = ["-" + argumentNameBaseFolder: "",
                 "-" + argumentNameBaseLanguage : "en.lproj",
                 "-" + argumentListOfLanguageFolders : ""]

// MARK: - main

/// read arguments from command line and store in arguments
read(commandLineArguments: CommandLine.arguments, storeIn: &arguments)



// MARK: - private functions

private func read(commandLineArguments : [String], storeIn: inout [String : String]) {
    
    /// - if commandLineArguments is not uneven, then exit
    /// - should be ueven because script name is always included
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
            
            fatalError("invalid argument name : " + argumentName)
            
        }
    }
    
}



