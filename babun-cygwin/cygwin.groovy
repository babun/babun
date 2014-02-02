#!/usr/bin/env groovy
import static java.lang.System.*

execute()

def execute() {
    File repoFolder, outputFolder
    try {
        checkArguments()
        (repoFolder, outputFolder) = initEnvironment()
        File cygwinInstaller = downloadCygwinInstaller(outputFolder)
        installCygwin(cygwinInstaller, repoFolder, outputFolder)
        cygwinInstaller.delete()
    } catch (Exception ex) {
        error("ERROR: Unexpected error occurred: " + ex + " . Quitting!", true)
        ex.printStackTrace()
        exit(-1)
    }
}

def checkArguments() {
    if (this.args.length != 2) {
        error("Usage: cygwin.groovy <repo_folder> <output_folder>")
        exit(-1)
    }
}

def initEnvironment() {
    File repoFolder = new File(this.args[0])
    File outputFolder = new File(this.args[1])
    if (outputFolder.exists()) {
        println "Deleting output folder ${outputFolder.getAbsolutePath()}"
        outputFolder.deleteDir()
    }
    outputFolder.mkdir()
    return [repoFolder, outputFolder]
}

def downloadCygwinInstaller(File outputFolder) {
    println "Downloading cygwin"
    File cygwinInstaller = new File(outputFolder, "setup-x86.exe")
    use(FileBinaryCategory) {
        cygwinInstaller << "http://cygwin.com/setup-x86.exe".toURL()
    }
    return cygwinInstaller
}

def installCygwin(File cygwinInstaller, File repoFolder, File outputFolder) {
    println "Installing cygwin"
    String installCommand = "\"${cygwinInstaller.absolutePath}\" " +
            "--quiet-mode " +
            "--local-install " +
            "--local-package-dir \"${repoFolder.absolutePath}\" " +
            "--root \"${outputFolder.absolutePath}\" " +
            "--no-shortcuts " +
            "--no-startmenu " +
            "--no-desktop " +
            "--packages cron,shutdown,openssh,ncurses,vim,nano,unzip,curl,rsync,ping,links,wget,httping,time"
//    println installCommand
//    executeCmd(installCommand, 10)
      new File(outputFolder, "cygwin.output").createNewFile()
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