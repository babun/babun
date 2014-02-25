#!/usr/bin/env groovy
import static java.lang.System.*

execute()

def execute() {
    File rootFolder, cygwinFolder, outputFolder
    try {
        checkArguments()
        (rootFolder, cygwinFolder, outputFolder) = initEnvironment()
        copyCygwin(cygwinFolder, outputFolder)
        // copyBabunToEtc(rootFolder, outputFolder)
        installCore(outputFolder)    
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
      fileset( dir: "${cygwinFolder.absolutePath}", defaultexcludes:"no" )
    }
}

/*
def copyBabunToEtc(File rootFolder, File outputFolder) {
    println "Installing babun core"
    new AntBuilder().copy( todir: "${outputFolder.absolutePath}/cygwin/usr/local/etc/babun/source", quiet: true ) {
      fileset( dir: "${rootFolder.absolutePath}", defaultexcludes:"no" ) {
            exclude(name: "target/**")
            exclude(name: "*.log")
            exclude(name: "*.full")
        }
    }
}
*/

def installCore(File outputFolder) {
    // rebase dll's
    executeCmd("${outputFolder.absolutePath}/cygwin/bin/dash.exe -c '/usr/bin/rebaseall'", 5)

    // setup bash invoked
    String bash = "${outputFolder.absolutePath}/cygwin/bin/bash.exe -l"
    
    // checkout babun
    executeCmd("${bash} -c \"git config --global http.sslverify 'false'; git clone https://github.com/babun/babun.git /usr/local/etc/babun/source\"", 5)
    
    // remove windows new line feeds
    String dos2unix = "find /usr/local/etc/babun/source/babun-core -type f -exec dos2unix {} \\;"
    executeCmd("${bash} -c \"${dos2unix}\"", 5)

    // make installer executable
    String chmod = "find /usr/local/etc/babun/source/babun-core -type f -regex '.*sh' -exec chmod 755 {} \\;"
    executeCmd("${bash} -c \"${chmod}\"", 5)

    // run babun installer - yay!
    executeCmd("${bash} \"/usr/local/etc/babun/source/babun-core/tools/install.sh\"", 5)
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
