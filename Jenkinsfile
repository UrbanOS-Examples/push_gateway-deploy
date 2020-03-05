library(
    identifier: 'pipeline-lib@4.7.0',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties([
    pipelineTriggers([scos.dailyBuildTrigger()]),
    parameters([
        booleanParam(defaultValue: false, description: 'Deploy to development environment?', name: 'DEV_DEPLOYMENT'),
        string(defaultValue: 'development', description: 'Image tag to deploy to dev environment', name: 'DEV_IMAGE_TAG')
    ])
])

def doStageIf = scos.&doStageIf
def doStageIfDeployingToDev = doStageIf.curry(env.DEV_DEPLOYMENT == "true")
def doStageIfMergedToMaster = doStageIf.curry(scos.changeset.isMaster && env.DEV_DEPLOYMENT == "false")
def doStageIfRelease = doStageIf.curry(scos.changeset.isRelease)

node ('infrastructure') {
    ansiColor('xterm') {
        scos.doCheckoutStage()

        doStageIfDeployingToDev('Deploy to Dev') {
            deployTo(environment: 'dev', extraArgs: "--recreate-pods --set image.tag=${env.DEV_IMAGE_TAG}")
        }

        doStageIfMergedToMaster('Process Dev job') {
            scos.devDeployTrigger('push_gateway', 'development', 'smartcolumbusos')
        }

        doStageIfMergedToMaster('Deploy to Staging') {
            deployTo(environment: 'staging')
            scos.applyAndPushGitHubTag('staging')
        }

        doStageIfRelease('Deploy to Production') {
            deployTo(environment: 'prod')
            scos.applyAndPushGitHubTag('prod')
        }
    }
}

def deployTo(params = [:]) {
    def environment = params.get('environment')
    def extraArgs = params.get('extraArgs', '')
    if (environment == null) throw new IllegalArgumentException("environment must be specified")

    scos.withEksCredentials(environment) {
        def terraformOutputs = scos.terraformOutput(environment)
        def dnsZone = terraformOutputs.internal_dns_zone_name.value
        def rootDnsZone = terraformOutputs.root_dns_zone_name.value

        sh("""#!/bin/bash
            set -xe

            helm init --client-only
            helm upgrade --install push-gateway chart/ \
                --namespace=streaming-services \
                --values=push-gateway-base.yaml \
                ${extraArgs}
        """.trim())
    }
}
