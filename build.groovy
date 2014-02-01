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
    println "Executing -> clean"
    File target = getTarget()
    if (target.exists()) {
        target.deleteDir()
    }
}

def doPackage() {
    println "Executing -> package"
    executeBabunPackages()
    executeBabunCygwin()
}

def executeBabunPackages() {
    String module = "babun-packages"
    File packagesOut = new File(getTarget(), module)
    if (packagesOut.exists()) {
        println "Skipping -> ${module}"
        return
    }
    println "Executing -> ${module}"
    File script = new File(getRoot(), "${module}/packages.groovy")
    File conf = new File(getRoot(), "${module}/conf/")
    File out = new File(getTarget(), "${module}")
    String command = "${script.getAbsolutePath()} ${conf.getAbsolutePath()} ${out.getAbsolutePath()}"
    executeCmd(command, 10)
}

def executeBabunCygwin() {
    String module = "babun-cygwin"
    println "Executing -> ${module}"
}

File getTarget() {
    return new File(getRoot(), "target")
}

File getRoot() {
    return new File(getClass().protectionDomain.codeSource.location.path).parentFile
}

int executeCmd(String command, int timeout) {
    def process = command.execute()
    process.consumeProcessOutput(out, err)
    process.waitForOrKill(timeout * 60000)
    return process.exitValue()
}


