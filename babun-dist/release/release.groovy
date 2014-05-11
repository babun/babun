#!/usr/bin/env groovy
@Grapes(
        @Grab(group = 'org.codehaus.groovy.modules.http-builder', module = 'http-builder', version = '0.6')
)
import org.apache.http.*
import org.apache.http.entity.FileEntity
import org.apache.http.protocol.HttpContext
import groovyx.net.http.*

import static groovyx.net.http.Method.*
import static groovyx.net.http.ContentType.*
import static java.lang.System.exit

execute()

def execute() {
    String repo, pkg, version, user, secret
    File artifact
    (repo, pkg, version, artifact, user, secret) = initEnvironment();
    RESTClient client = initClient(user, secret)
    if (!doesContainVersion(client, user, repo, pkg, version)) {
        println "Creating version [${version}]"
        createVersion(client, user, repo, pkg, version)
    }
    println "Uploading artifact [${artifact.name}]"
    uploadContent(client, user, repo, pkg, version, artifact)
}

def checkArguments() {
    if (this.args.length != 6) {
        error("Usage: release.groovy <repo> <package> <version> <artifact> <user> <secret>")
        exit(-1)
    }
}

def initEnvironment() {
    String repo = this.args[0]
    String pkg = this.args[1]
    String version = this.args[2]
    File artifact = new File(this.args[3])
    assert artifact.exists()
    String user = this.args[4]
    String secret = this.args[5]
    [repo, pkg, version, artifact, user, secret]
}

def doesContainVersion(def client, String user, String repo, String pkg, String version) {
    def response = client.get(path: "packages/${user}/${repo}/${pkg}".toString())
    assert 200 == response.status
    def versions = response.data.versions as List
    return versions?.contains(version)
}

def createVersion(def client, String user, String repo, String pkg, String version) {
    def response = client.post(path: "packages/${user}/${repo}/${pkg}/versions".toString(),
            contentType: JSON,
            requestContentType: JSON,
            body: [name: version, desc: version])
    assert 201 == response.status
}

def uploadContent(def client, String user, String repo, String pkg, String version, File file) {
    def putClient = client
    String zip = "application/zip"
    String url = "content/${user}/${repo}/${pkg}/${version}/${file.name};".toString()
    String options = "publish=0;explode=0;"
    String path = url + options
    assert file.exists()
    putClient.encoder.putAt(zip, this.&encodeZipFile)
    putClient.parser.'application/json' = putClient.parser.'text/plain'
    def response = putClient.put(path: path, body: file, contentType: ANY, requestContentType: zip)
    assert 201 == response.status
}

def encodeZipFile(Object data) throws UnsupportedEncodingException {
    def entity = new FileEntity((File) data, "application/zip");
    entity.setContentType("application/zip");
    return entity
}

def initClient(String user, String pass) {
    def bintrayClient = new RESTClient("https://bintray.com/api/v1/")
    String basic = (user + ":" + pass).bytes.encodeBase64().toString()
    bintrayClient.client.addRequestInterceptor(
            new HttpRequestInterceptor() {
                void process(HttpRequest httpRequest, HttpContext httpContext) {
                    httpRequest.addHeader('Cache-Control', 'no-cache, no-store, no-transform, must-revalidate')
                    httpRequest.addHeader('Pragma', 'no-cache')
                    httpRequest.addHeader('Authorization', 'Basic ' + basic)
                }
            })
    bintrayClient
}