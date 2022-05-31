# findMissingStringsXcode

Script to update .string files in Xcode project


arguments are list of argument name and argument value. Argument name starts with '-'. Argument names and argument values are seperated by sapce.
- Reads string resource files in one language folder (usually Storyboard/en.lproj)

- For each file, and each string resource, reads key and value (key being used in string-loading routines NSLocalizedString, value being the actual text used)

- The same for a list of other language folders (eg nl.lproj), reads every file and reads key/value pairs

- Lists missing strings in the language folder and appends the base language strings to the other language files


Arguments:

  -basefolder : Storyboards foldername, example (using https://github.com/JohanDegraeve/xdripswift as sample Project) '/Users/johandegraeve/temp/xdripswift/xdrip/Storyboards'

  -baseLanguage : The language from which strings will be copied to other languages, example 'en.lproj'

  -listOfLanguageFolders : list of language folders, comma seperated, example (using xdripswift as sample Project) 'nl.lproj,ar.lproj'

  -swiftFilesFolder : swift files foldernames, used to retrieve the comments. Example : '/Users/johandegraeve/temp/xdripswift/xdrip/Texts'



Example arguments : uses en.lproj as base language, missing strings in folder nl.lproj and ar.lproj will be added (if necessary missing files are created), inclusive comments found in swift files

   -basefolder /Users/johandegraeve/temp/xdripswift/xdrip/Storyboards -baseLanguage en.lproj -listOfLanguageFolders nl.lproj,ar.lproj -swiftFilesFolder /Users/johandegraeve/temp/xdripswift/xdrip/Texts
   
   
For the xdripswift project

./findMissingStrings -basefolder /Users/johandegraeve/temp/xdripswift/xdrip/Storyboards -baseLanguage en.lproj -listOfLanguageFolders nl.lproj,ar.lproj,de.lproj,es.lproj,fi.lproj,fr.lproj,it.lproj,pl-PL.lproj,pt.lproj,ru.lproj,sl.lproj,zh.lproj,sv.lproj, uk.lproj -swiftFilesFolder /Users/johandegraeve/temp/xdripswift/xdrip/Texts

For the xdripswift Widget

./findMissingStrings -basefolder /Users/johandegraeve/temp/xdripswift/xdrip/Storyboards -baseLanguage en.lproj -listOfLanguageFolders nl.lproj,ar.lproj,de.lproj,es.lproj,fi.lproj,fr.lproj,it.lproj,pl-PL.lproj,pt.lproj,ru.lproj,sl.lproj,zh.lproj,sv.lproj,da.lproj, uk.lproj -swiftFilesFolder /Users/johandegraeve/temp/xdripswift/xdrip/Texts

