#!/usr/bin/env groovy
import static java.lang.System.*
import static java.lang.System.getenv

VERSION = new File("${getRoot()}/babun.version").text.trim()
TEN_MINUTES = 10
TWENTY_MINUTES = 20
ARG_64BIT = "--64bit"

execute()

def execute() {
    log "EXEC"
    if (this.args.length < 1) {
        printUsageAndExit();
    }
    String mode = this.args[0]
    String arch = "x86"

    List args = this.args.drop(1)
    if (ARG_64BIT in args) {
        arch = "x86_64"
        args -= ARG_64BIT
    }
    if (args) {
        // Unrecognized arguments
        printUsageAndExit();
    }

    if (mode == "clean") {
        doClean()
    } else if (mode == "cygwin") {
        doCygwin(arch)
    } else if (mode == "package") {
        doPackage(arch)
    } else if (mode == "release") {
        doRelease(arch)
    } else {
        printUsageAndExit();
    }
    log "FINISHED"
}

def printUsageAndExit() {
    err.println "Usage: build.groovy <clean|cygwin|package|release> [args...]"
    exit(-1)
}

def initEnvironment() {
    File target = getTarget()
    if (!target.exists()) {
        target.mkdir()
    }
}

def doClean() {
    log "EXEC clean"
    if (this.args.length > 1) {
        printUsageAndExit();
    }
    File target = getTarget()
    if (target.exists()) {
        if (!target.deleteDir()) {
            throw new RuntimeException("Cannot delete target folder")
        }
    }
}

def doPackage(String arch) {
    log "EXEC package"  
    executeBabunPackages(arch)
    executeBabunCygwin(arch)
    executeBabunCore()
    executeBabunDist(arch)
}

def doCygwin(String arch) {
    executeBabunPackages(arch)
    boolean downloadOnly=true
    executeBabunCygwin(arch, downloadOnly)
}

def doRelease(String arch) {
    log "EXEC release"
    doPackage(arch)
    executeRelease()
}

def executeBabunPackages(String arch) {
    String module = "babun-packages"
    log "EXEC ${module}"
    if (shouldSkipModule(module)) return
    File workingDir = new File(getRoot(), module);
    String conf = new File(getRoot(), "${module}/conf/").absolutePath
    String out = new File(getTarget(), "${module}").absolutePath
    def command = ["groovy", "packages.groovy", conf, out, arch]
    executeCmd(command, workingDir, TEN_MINUTES)
}

def executeBabunCygwin(String arch, boolean downloadOnly = false) {
    String module = "babun-cygwin"
    log "EXEC ${module}"
    File workingDir = new File(getRoot(), module);
    String input = workingDir.absolutePath
    String repo = new File(getTarget(), "babun-packages").absolutePath
    String out = new File(getTarget(), "${module}").absolutePath
    String pkgs = new File(getRoot(), "babun-packages/conf/cygwin.${arch}.packages")
    String downOnly = downloadOnly as String
    println "Download only flag set to: ${downOnly}"
    def command = ["groovy", "cygwin.groovy", repo, input, out, pkgs, downOnly, arch]
    executeCmd(command, workingDir, TEN_MINUTES)
}

def executeBabunCore() {
    String module = "babun-core"
    log "EXEC ${module}"
    if (shouldSkipModule(module)) return
    File workingDir = new File(getRoot(), module);
    String root = getRoot().absolutePath
    String cygwin = new File(getTarget(), "babun-cygwin/cygwin").absolutePath
    String out = new File(getTarget(), "${module}").absolutePath    
    String branch = getenv("babun_branch") ? getenv("babun_branch") : "release"
    println "Taking babun branch [${branch}]"
    def command = ["groovy", "core.groovy", root, cygwin, out, branch]
    executeCmd(command, workingDir, TEN_MINUTES)
}

def executeBabunDist(String arch) {
    String module = "babun-dist"
    log "EXEC ${module}"
    if (shouldSkipModule(module)) return
    File workingDir = new File(getRoot(), module);
    String input = workingDir.absolutePath
    String cygwin = new File(getTarget(), "babun-core/cygwin").absolutePath
    String out = new File(getTarget(), "${module}").absolutePath
    def command = ["groovy", "dist.groovy", cygwin, input, out, VERSION, arch]
    executeCmd(command, workingDir, TEN_MINUTES)
}

def executeRelease() {
    log "EXEC release"
    assert getenv("bintray_user") != null
    assert getenv("bintray_secret") != null
    File artifact = new File(getTarget(), "babun-dist/babun-${VERSION}-dist.zip")
    def args = ["groovy", "babun-dist/release/release.groovy", "babun", "babun-dist", VERSION,
            artifact.absolutePath, getenv("bintray_user"), getenv("bintray_secret")]
    executeCmd(args, getRoot(), TWENTY_MINUTES)
}

def shouldSkipModule(String module) {
    File out = new File(getTarget(), module)
    log "Checking if skip module ${module} -> folder ${out.absolutePath}"
    if (out.exists()) {
        log "SKIP ${module}"
        return true
    }
    log "DO NOT SKIP ${module}"
    return false
}

File getTarget() {
    return new File(getRoot(), "target")
}

File getRoot() {
    return new File(getClass().protectionDomain.codeSource.location.path).parentFile
}

def executeCmd(List<String> command, File workingDir, int timeout) {
    ProcessBuilder processBuilder = new ProcessBuilder(command)
    processBuilder.directory(workingDir)
    Process process = processBuilder.start()
    addShutdownHook { process.destroy() }
    process.consumeProcessOutput(out, err)
    process.waitForOrKill(timeout * 60000)
    assert process.exitValue() == 0
}

def getReleaseScript() {
    new File(getRoot(), "release.groovy")
}

def log(String msg) {
    println "[${new Date()}] ${msg}"
}