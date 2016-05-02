#!/usr/bin/env groovy
import static java.lang.System.*
import static groovy.io.FileType.*

execute()

def execute() {
    File confFolder, outputFolder
    String setupVersion
    try {
        checkArguments()
        (confFolder, outputFolder, setupVersion) = initEnvironment()
        downloadPackages(confFolder, outputFolder, "x86")
        copyPackagesListToTarget(confFolder, outputFolder, "x86")
    } catch (Exception ex) {
        error("Unexpected error occurred: " + ex + " . Quitting!")
        ex.printStackTrace()
        exit(-1)
    }
}

def checkArguments() {
    if (this.args.length != 2) {
        error("Usage: packages.groovy <conf_folder> <output_folder>", true)
        exit(-1)
    }
}

def initEnvironment() {
    File confFolder = new File(this.args[0])
    File outputFolder = new File(this.args[1])
    if (!outputFolder.exists()) {
        outputFolder.mkdir()
    }    
    return [confFolder, outputFolder]
}

def copyPackagesListToTarget(File confFolder, File outputFolder, String bitVersion) {
    File packagesFile = new File(confFolder, "cygwin.${bitVersion}.packages")
    File outputFile = new File(outputFolder, "cygwin.${bitVersion}.packages")
    outputFile.createNewFile()
    outputFile << packagesFile.text
}

def downloadPackages(File confFolder, File outputFolder, String bitVersion) {
    File packagesFile = new File(confFolder, "cygwin.${bitVersion}.packages")
    def rootPackages = packagesFile.readLines().findAll() { it }
    def repositories = new File(confFolder, "cygwin.repositories").readLines().findAll() { it }
    def processed = [] as Set
    for (repo in repositories) {
        String setupIni = downloadSetupIni(repo, bitVersion, outputFolder)
        for (String rootPkg : rootPackages) {
            if (processed.contains(rootPkg.trim())) continue
            def processedInStep = downloadRootPackage(repo, setupIni, rootPkg.trim(), processed, outputFolder)
            processed.addAll(processedInStep)
        }
        rootPackages.removeAll(processed)
        if (rootPackages.isEmpty()) {
            return
        }
    }
    if (!rootPackages.isEmpty()) {
        error("Could not download the following ${rootPackages}! Quitting!")
        exit(-1)
    }
}

def downloadSetupIni(String repository, String bitVersion, File outputFolder) {
    println "Downloading [setup.ini] from repository [${repository}]"
    String setupIniUrl = "${repository}/${bitVersion}/setup.ini"
    String downloadSetupIni = "wget -l 2 -r -np -q --cut-dirs=3 -P " + outputFolder.getAbsolutePath() + " " + setupIniUrl    
    executeCmd(downloadSetupIni, 5)
    String setupIniContent = setupIniUrl.toURL().text
    return setupIniContent
}

def downloadRootPackage(String repo, String setupIni, String rootPkg, Set<String> processed, File outputFolder) {
    def processedInStep = [] as Set
    println "Processing top-level package [$rootPkg]"
    def packagesToProcess = [] as Set
    try {
        buildPackageDependencyTree(setupIni, rootPkg, packagesToProcess)
        for (String pkg : packagesToProcess) {
            if (processed.contains(pkg) || processedInStep.contains(pkg)) continue
            String pkgInfo = parsePackageInfo(setupIni, pkg)
            String pkgPath = parsePackagePath(pkgInfo)
            if (pkgPath) {
                println "  Downloading package [$pkg]"
                if (downloadPackage(repo, pkgPath, outputFolder)) {
                    processedInStep.add(pkg)
                }
            } else if (pkgInfo) {
                // packages doesn't have binary file
                processedInStep.add(pkg)
            } else {
                println "  Cannot find package [$pkg] in the repository"
                processedInStep = [] as Set // reset as the tree could not be fetched
                break;
            }
        }
    } catch (Exception ex) {
        error("Could not download dependency tree for [$rootPkg]")
        ex.printStackTrace()
        processedInStep = [] as Set
    }
    processedInStep
}

def buildPackageDependencyTree(String setupIni, String pkgName, Set<String> result) {
    String pkgInfo = parsePackageInfo(setupIni, pkgName)
    result.add(pkgName)
    if (!pkgInfo) {
        throw new RuntimeException("Cannot find dependencies of [${pkgName}]")
    }
    String[] deps = parsePackageRequires(pkgInfo)
    for (String dep : deps) {
        if (!result.contains(dep.trim())) {
            buildPackageDependencyTree(setupIni, dep.trim(), result)
        }
    }
}

def parsePackageRequires(String pkgInfo) {
    String requires = pkgInfo?.split("\n")?.find() { it.startsWith("requires:") }
    return requires?.replace("requires:", "")?.trim()?.split("\\s")
}

def parsePackageInfo(String setupIni, String packageName) {
    return setupIni?.split("(?=@ )")?.find() { it.contains("@ ${packageName}") }
}

def parsePackagePath(String pkgInfo) {
    String version = pkgInfo?.split("\n")?.find() { it.startsWith("install:") }
    String[] tokens = version?.replace("install:", "")?.trim()?.split("\\s")
    return tokens?.length > 0 ? tokens[0] : null
}

def downloadPackage(String repositoryUrl, String packagePath, File outputFolder) {
    String packageUrl = repositoryUrl + packagePath
    String downloadCommand = "wget -l 2 -r -np -q --cut-dirs=3 -P " + outputFolder.getAbsolutePath() + " " + packageUrl
    if (executeCmd(downloadCommand, 5) != 0) {
        println "Could not download " + packageUrl
        return false
    }
    return true
}

int executeCmd(String command, int timeout) {
    def process = command.execute()
    addShutdownHook { process.destroy() }
    process.consumeProcessOutput(out, err)
    process.waitForOrKill(timeout * 60000)
    return process.exitValue()
}

def error(String message, boolean noPrefix = false) {
    err.println((noPrefix ? "" : "ERROR: ") + message)
}
