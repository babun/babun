#!/usr/bin/env groovy
import static java.lang.System.*

execute()

def execute() {
    File rootFolder, cygwinFolder, outputFolder
    try {
        checkArguments()
        (rootFolder, cygwinFolder, outputFolder) = initEnvironment()
        copyCygwin(cygwinFolder, outputFolder)
        installCore(rootFolder, outputFolder)

    } catch (Exception ex) {
        error("ERROR: Unexpected error occurred: " + ex + " . Quitting!", true)
        ex.printStackTrace()
        exit(-1)
    }
}

def checkArguments() {
    if (this.args.length != 3) {
        error("Usage: core.groovy <babun_root> <cygwin_folder> <output_folder>")
        exit(-1)
    }
}

def initEnvironment() {
    File rootFolder = new File(this.args[0])
    File cygwinFolder = new File(this.args[1])
    File outputFolder = new File(this.args[2])
    if (outputFolder.exists()) {
        println "Deleting output folder ${outputFolder.getAbsolutePath()}"
        outputFolder.deleteDir()
    }
    outputFolder.mkdir()
    return [rootFolder, cygwinFolder, outputFolder]
}

def copyCygwin(File cygwinFolder, File outputFolder) {
    new AntBuilder().copy( todir: "${outputFolder.absolutePath}/cygwin", quiet: true ) {
      fileset( dir: "${cygwinFolder.absolutePath}" )
    }
}

def installCore(File rootFolder, File outputFolder) {
    println "Installing babun core"
    new AntBuilder().copy( todir: "${outputFolder.absolutePath}/cygwin/usr/local/etc/babun", quiet: true ) {
      fileset( dir: "${rootFolder.absolutePath}" )
    }
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
