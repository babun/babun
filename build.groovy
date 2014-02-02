#!/usr/bin/env groovy
import static java.lang.System.*

execute()

def execute() {
    checkArguments()
    String mode = this.args[0]
    if (mode == "clean") {
        doClean()
    } else if (mode == "package") {
        doPackage()
    }
}

def checkArguments() {
    if (this.args.length != 1 || !this.args[0].matches("clean|package")) {
        err.println "Usage: build.groovy <clean|package>"
        exit(-1)
    }
}

def initEnvironment() {
    File target = getTarget()
    if (!target.exists()) {
        target.mkdir()
    }
}

def doClean() {
    println "EXEC clean"
    File target = getTarget()
    if (target.exists()) {
        target.deleteDir()
    }
}

def doPackage() {
    println "EXEC package"
    executeBabunPackages()
    executeBabunCygwin()
    // executeBabunCore()
    // executeBabunInstaller()
}

def executeBabunPackages() {
    String module = "babun-packages"
    if (shouldSkipModule(module)) return
    File workingDir = new File(getRoot(), module);
    String conf = new File(getRoot(), "${module}/conf/").absolutePath
    String out = new File(getTarget(), "${module}").absolutePath
    def command = ["groovy", "packages.groovy", conf, out]
    executeCmd(command, workingDir, 10)
}

def executeBabunCygwin() {
    String module = "babun-cygwin"
    if (shouldSkipModule(module)) return
    File workingDir =new File(getRoot(), module);
    String repo = new File(getTarget(), "babun-packages").absolutePath
    String out = new File(getTarget(), "${module}").absolutePath
    def command = ["groovy", "cygwin.groovy", repo, out]
    executeCmd(command, workingDir, 10)
}

def shouldSkipModule(String module) {
    File out = new File(getTarget(), module)
    if (out.exists()) {
        println "SKIP ${module}"
        return true
    }
    println "EXEC ${module}"
    return false
}

File getTarget() {
    return new File(getRoot(), "target")
}

File getRoot() {
    return new File(getClass().protectionDomain.codeSource.location.path).parentFile
}

int executeCmd(List<String> command, File workingDir, int timeout) {
    ProcessBuilder processBuilder = new ProcessBuilder(command)
    processBuilder.directory(workingDir)
    Process process = processBuilder.start()
    addShutdownHook { process.destroy() }
    process.consumeProcessOutput(out, err)
    process.waitForOrKill(timeout * 60000)
    return process.exitValue()
}
