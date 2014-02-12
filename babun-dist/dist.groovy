#!/usr/bin/env groovy
import static java.lang.System.err
import static java.lang.System.exit

execute()

def execute() {
    File cygwinFolder, inputFolder, outputFolder
    String version
    try {
        checkArguments()
        (cygwinFolder, inputFolder, outputFolder, version) = initEnvironment()
        // prepare .babun
        copyCygwin(cygwinFolder, outputFolder)
        copyTools(inputFolder, outputFolder)
        copyStartScripts(inputFolder, outputFolder)

        // handle symlinks
        copySymlinksScripts(inputFolder, outputFolder)
        findSymlinks(outputFolder)        

        // prepare Dist
        zipBabun(outputFolder)
        copyInstallScripts(inputFolder, outputFolder)
        createBabunDist(outputFolder, version)

    } catch (Exception ex) {
        error("ERROR: Unexpected error occurred: " + ex + " . Quitting!", true)
        ex.printStackTrace()
        exit(-1)
    }
}

def checkArguments() {
    if (this.args.length != 4) {
        error("Usage: dist.groovy <cygwin_folder> <input_folder> <output_folder> <version>")
        exit(-1)
    }
}

def initEnvironment() {
    File cygwinFolder = new File(this.args[0])
    File inputFolder = new File(this.args[1])
    File outputFolder = new File(this.args[2])
    String version = this.args[3] as String
    if (outputFolder.exists()) {
        println "Deleting output folder ${outputFolder.getAbsolutePath()}"
        outputFolder.deleteDir()
    }
    outputFolder.mkdir()
    return [cygwinFolder, inputFolder, outputFolder, version]
}

def copyCygwin(File cygwinFolder, File outputFolder) {
    new AntBuilder().copy(todir: "${outputFolder.absolutePath}/.babun/cygwin", quiet: true) {
        fileset(dir: "${cygwinFolder.absolutePath}") {
            exclude(name: "Cygwin.bat")
            exclude(name: "Cygwin.ico")
            exclude(name: "Cygwin-Terminal.ico")
        }
    }
}

def copyTools(File inputFolder, File outputFolder) {
    new AntBuilder().copy(todir: "${outputFolder.absolutePath}/.babun/tools", quiet: true) {
        fileset(dir: "${inputFolder.absolutePath}/tools")
    }
}

def copyStartScripts(File inputFolder, File outputFolder) {
    new AntBuilder().copy(todir: "${outputFolder.absolutePath}/.babun", quiet: true) {
        fileset(dir: "${inputFolder.absolutePath}/start")
    }
}

def copySymlinksScripts(File inputFolder, File outputFolder) {
    new AntBuilder().copy(todir: "${outputFolder.absolutePath}/.babun/cygwin/etc/postinstall", quiet: true) {
        fileset(dir: "${inputFolder.absolutePath}/symlinks")
    }    
}

def findSymlinks(File outputFolder) {
    File cygwinOutputFolder = new File(outputFolder, ".babun/cygwin")
    String bashExe = cygwinOutputFolder.absolutePath + "/bin/bash.exe"
    String findSymlinksSh = "/etc/postinstall/find_symlinks.sh"
    String bashCmd = "${bashExe} ${findSymlinksSh}"
    executeCmd(bashCmd, 5)
    File findSymlinksFile = new File(cygwinOutputFolder, findSymlinksSh)
    findSymlinksFile.delete()
}

def zipBabun(File outputFolder) {
    new AntBuilder().zip(destFile: "${outputFolder.absolutePath}/dist/babun.zip", level: 9) {
        fileset(dir: "${outputFolder.absolutePath}") {
            include(name: '.babun/**')
        }
    }
}

def copyInstallScripts(File inputFolder, File outputFolder) {
    new AntBuilder().copy(todir: "${outputFolder.absolutePath}/dist", quiet: true) {
        fileset(dir: "${inputFolder.absolutePath}/install")
    }
}

def createBabunDist(File outputFolder, String version) {
    // rename dist folder
    File dist = new File(outputFolder, "dist")
    File distWithVersion = new File(outputFolder, "babun-${version}")
    dist.renameTo(distWithVersion)

    // zip dist folder
    new AntBuilder().zip(destFile: "${outputFolder.absolutePath}/babun-${version}-dist.zip", level: 3) {
        fileset(dir: "${outputFolder.absolutePath}") {
            include(name: "babun-${version}/**")
        }
    }
}

def error(String message, boolean noPrefix = false) {
    err.println((noPrefix ? "" : "ERROR: ") + message)
}

def executeCmd(String command, int timeout) {
    def process = command.execute()
    addShutdownHook { process.destroy() }
    process.consumeProcessOutput(out, err)
    process.waitForOrKill(timeout * 60000)
    assert process.exitValue() == 0
}