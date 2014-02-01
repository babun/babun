#!/usr/bin/env groovy

execute()

def execute() {
    checkArguments()
    String mode = this.args[0]
    if(mode == "clean") {
	doClean()
    } else if(mode == "package") {
	doPackage()
    }
}

def checkArguments() {
    if(this.args.length != 1 || !this.args[0].matches("clean|package")) {
        System.err.println "Usage: build.groovy <clean|package>"
        System.exit(-1)
    }
}

def doClean() {
    
}

def doPackage() {
    
}
