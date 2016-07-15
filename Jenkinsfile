#!groovy
def starttime = System.currentTimeMillis()
stage "provision build node"
node('nodejs4') {  //this node label must match jenkins slave with tools installed to build our project
    println("begin: build node ready in ${(System.currentTimeMillis() - starttime) /1000}  seconds")
    wrap([$class: 'TimestamperBuildWrapper']) {  //wrap each Jenkins job console output line with timestamp
        stage "build setup"
        checkout scm  //scm location comes from Jenkins build job definition on the Jenkins build server.  This Jenkinsfile doesn't need to care about the specific address of the git repository.
        whereami()
        echo "Building version ${regexVersion()}"
//        buildParallel(starttime)
        buildSingle(starttime)
    }
}

private void buildParallel(starttime) {
    stage 'production war'
    sh "mvn  -B clean -Pprod verify -DskipTests"  //just build a prod war file quickly
    stage 'docker image/ prod test'
    parallel Java: {  //test the project in one thread
        step([$class: 'ArtifactArchiver',artifacts: '**/target/*.war',fingerprint: true])
        sh "TZ=America/Denver mvn  -B -Pprodtest verify"  //pom.xml must have prodtest profile in order for karma tests to execute during test phase
        step([$class: 'JUnitResultArchiver',testResults: '**/target/surefire-reports/TEST-*.xml'])
        step([$class: 'JUnitResultArchiver',testResults: '**/target/test-results/karma/TESTS-results.xml',allowEmptyResults: true])
        //name pattern must match path in ./src/test/javascript/karma.conf.js
        println("testing finished in ${(System.currentTimeMillis() - starttime) / 1000} seconds")

    },docker: { //build and run docker image from our production war in another thread
        sh "mvn -B docker:build"
        sh "docker-compose -f src/main/docker/app.yml up -d"  //start up the production app for manual inspection
        sh "docker-compose -f src/main/docker/app.yml ps"
        sh "echo \"app is starting... http://\$(docker info | sed -n 's/^Name: //'p):8080/\""
        println("app ready in ${(System.currentTimeMillis() - starttime) / 1000} seconds")
    }
    sh "echo \"Reminder: app should already be running at http://\$(docker info | sed -n 's/^Name: //'p):8080/\""
}

private void buildSingle(starttime) {
    stage 'production war/testing'
    sh "TZ=America/Denver mvn  -B -Pprod verify"
    step([$class: 'ArtifactArchiver',artifacts: '**/target/*.war',fingerprint: true])
    step([$class: 'JUnitResultArchiver',testResults: '**/target/surefire-reports/TEST-*.xml'])
    step([$class: 'JUnitResultArchiver',testResults: '**/target/test-results/karma/TESTS-results.xml',allowEmptyResults: true])
    stage 'docker build'
    sh "mvn -B docker:build"
    stage 'docker up'
    sh "docker-compose -f src/main/docker/app.yml up -d"
    sh "docker-compose -f src/main/docker/app.yml ps"
}

private boolean isMavenProject() {
    echo "looking for a pom.xml"
    if (new File("pom.xml").exists()) {  //sadly, Jenkins will generate security errors if this is used
        echo "detected a Maven project"
        true
    } else {
        false
    }
}

private void whereami() {
    /**
     * Runs a bunch of tools that we assume are installed on this node
     */
    echo "Build is running with these settings:"
    sh "pwd"
    sh "ls -la"
    sh "echo path is \$PATH"
    sh """
uname -a
java -version
mvn -v
docker ps
docker info
docker-compose -f src/main/docker/app.yml ps
docker-compose version
npm version
gulp --version
bower --version
"""
}

//def pomVersion(){
    //more accurate way to parse version # from pom.xml, but Jenkins pipeline generates many security errors
//    def pomtext = readFile('pom.xml')
//    def pomx = new XmlParser().parseText(pomtext)
//    pomx.version.text()
//}

def regexVersion(){
    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
    matcher ? matcher[1][1] : null   //blindly assume the 1st version occurence is the parent, and 2nd is our project
}











