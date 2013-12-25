#!/usr/bin/env groovy

File outputFolder
File confFolder
boolean includeSources

process()

def process() {
    checkArguments()
    initialize()
    buildPackage(confFolder, outputFolder, "x86", includeSources)            

}

def checkArguments() {
    if(this.args.length != 3) {
        System.err.println "Usage: packages.groovy <conf_folder> <output_folder> <include_sources>"
        System.exit(-1)
    }
}

def initialize() {
    confFolder = new File(this.args[0])    
    outputFolder = new File(this.args[1])
    includeSources = Boolean.valueOf(this.args[2])
    if(outputFolder.exists()) {
        println "Deleting output folder ${outputFolder.getAbsolutePath()}"
    	outputFolder.deleteDir()
    }
    outputFolder.mkdir()
}

def buildPackage(File confFolder, File outputFolder, String version, boolean includeSources) {    
  def packages = new File(confFolder, version + ".packages").readLines().findAll() { it }
  def repositories = new File(confFolder, "cygwin.repositories").readLines().findAll() { it }

  for(pkg in packages) {
    boolean downloaded = false
    for(repo in repositories) {
        println "Downloading package [$pkg] from [$repo]"
        downloaded = downloadPackage(pkg, version, repo, outputFolder, includeSources)
        if(downloaded) {
	  break
        }
    } 
  } 

}

def downloadPackage(String packageName, String version, String repositoryUrl, File outputFolder, boolean includeSources) {
    String packageUrl = repositoryUrl + version + "/release/" + packageName 
    String reject = includeSources ? " " : "-R *-src\\.* "
    String downloadCommand = "wget ${reject}-r -np --cut-dirs=2 -P " + outputFolder.getAbsolutePath() + " " + packageUrl
    println downloadCommand
    def downloadProcess = downloadCommand.execute()
    downloadProcess.consumeProcessOutput(System.out, System.err)
    downloadProcess.waitForOrKill(60000 * 3)
    int downloadStatus = downloadProcess.exitValue()
    if(downloadStatus != 0) {
	println "Cannot download " + packageUrl
	return false
    } 
    return true
}

