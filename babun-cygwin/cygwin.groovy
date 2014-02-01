#!/usr/bin/env groovy
import static java.lang.System.*

execute()

def execute() {
    File repoFolder, outputFolder
    try {
        checkArguments()
        (repoFolder, outputFolder) = initEnvironment()
        installCygwin(repoFolder, outputFolder)
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

def installCygwin(File repoFolder, File outputFolder) {
    println "Installing cygwin"
    String installCommand = "setup-x86.exe " +
            "--quiet-mode " +
            "--local-install " +
            "--local-package-dir '${repoFolder.absolutePath}' " +
            "--root '${outputFolder.absolutePath}' " +
            "--no-shortcuts " +
            "--no-startmenu " +
            "--no-desktop " +
            "--packages cron,shutdown,openssh,ncurses,vim,nano,unzip,curl,rsync,ping,links,wget,httping,time"
//    println installCommand
    executeCmd(installCommand, 10)
}


int executeCmd(String command, int timeout) {
    def process = command.execute()
    process.consumeProcessOutput(out, err)
    process.waitForOrKill(timeout * 60000)
    return process.exitValue()
}

def error(String message, boolean noPrefix = false) {
    err.println((noPrefix ? "" : "ERROR: ") + message)
}