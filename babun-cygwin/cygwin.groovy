#!/usr/bin/env groovy
import static java.lang.System.*

execute()

def execute() {
    File repoFolder, inputFolder, outputFolder, cygwinFolder, pkgsFile
    try {
        checkArguments()
        (repoFolder, inputFolder, outputFolder, cygwinFolder, pkgsFile) = initEnvironment()
        // install cygwin
        File cygwinInstaller = downloadCygwinInstaller(outputFolder)
        installCygwin(cygwinInstaller, repoFolder, cygwinFolder, pkgsFile)
        cygwinInstaller.delete()

        // handle symlinks
        copySymlinksScripts(inputFolder, cygwinFolder)
        findSymlinks(cygwinFolder)        
    } catch (Exception ex) {
        error("ERROR: Unexpected error occurred: " + ex + " . Quitting!", true)
        ex.printStackTrace()
        exit(-1)
    }
}

def checkArguments() {
    if (this.args.length != 4) {
        error("Usage: cygwin.groovy <repo_folder> <input_folder> <output_folder> <pkgs_file>")
        exit(-1)
    }
}

def initEnvironment() {
    File repoFolder = new File(this.args[0])
    File inputFolder = new File(this.args[1])
    File outputFolder = new File(this.args[2])
    File pkgsFile = new File(this.args[3])
    if (outputFolder.exists()) {
        println "Deleting output folder ${outputFolder.getAbsolutePath()}"
        outputFolder.deleteDir()
    }
    outputFolder.mkdir()
    File cygwinFolder = new File(outputFolder, "cygwin")
    cygwinFolder.mkdir()
    return [repoFolder, inputFolder, outputFolder, cygwinFolder, pkgsFile]
}

def downloadCygwinInstaller(File outputFolder) {
    println "Downloading cygwin"
    File cygwinInstaller = new File(outputFolder, "setup-x86.exe")
    use(FileBinaryCategory) {
        cygwinInstaller << "http://cygwin.com/setup-x86.exe".toURL()
    }
    return cygwinInstaller
}

def installCygwin(File cygwinInstaller, File repoFolder, File cygwinFolder, File pkgsFile) {    
    println "Installing cygwin"
    String pkgs = pkgsFile.text.trim().replace("\n", ",")    
    println "Packages to install: ${pkgs}"
    String installCommand = "\"${cygwinInstaller.absolutePath}\" " +
            "--quiet-mode " +
            "--local-install " +
            "--local-package-dir \"${repoFolder.absolutePath}\" " +
            "--root \"${cygwinFolder.absolutePath}\" " +
            "--no-shortcuts " +
            "--no-startmenu " +
            "--no-desktop " +
            "--packages " + pkgs
    println installCommand
    executeCmd(installCommand, 10)
}

def copySymlinksScripts(File inputFolder, File cygwinFolder) {
    new AntBuilder().copy(todir: "${cygwinFolder.absolutePath}/etc/postinstall", quiet: true) {
        fileset(dir: "${inputFolder.absolutePath}/symlinks", defaultexcludes:"no")
    }    
}

def findSymlinks(File cygwinFolder) {
    String symlinksFindScript = "/etc/postinstall/symlinks_find.sh"
    String findSymlinksCmd = "${cygwinFolder.absolutePath}/bin/bash.exe --norc --noprofile \"${symlinksFindScript}\""
    executeCmd(findSymlinksCmd, 10)
    new File(cygwinFolder, symlinksFindScript).delete()
}

def executeCmd(String command, int timeout) {
    println "Executing: ${command}"
    def process = command.execute()
    addShutdownHook { process.destroy() }
    process.consumeProcessOutput(out, err)
    process.waitForOrKill(timeout * 60000)
    assert process.exitValue() == 0
}

def error(String message, boolean noPrefix = false) {
    err.println((noPrefix ? "" : "ERROR: ") + message)
}

class FileBinaryCategory {
    def static leftShift(File file, URL url) {
        url.withInputStream { is ->
            file.withOutputStream { os ->
                def bs = new BufferedOutputStream(os)
                bs << is
            }
        }
    }
}