// Job: submit-testflight-groups-ios ("Async TestFlight Submission")
// Runs the TestFlight submission script the upstream iOS build compiled on the
// Mac (JWT, app id, params already baked in) — this job only executes that text.
// Deploy: Configure -> Definition = "Pipeline script" (NOT "from SCM"), paste, Save.
// Agent needs only bash/curl/grep/sed — no python3, openssl, credentials, or git.

pipeline {
    agent { label 'built-in' }

    parameters {
        text(name: 'SUBMIT_SCRIPT', defaultValue: '', description: 'Fully-compiled submission script, produced by the upstream iOS build on the Mac agent. This job only executes it.')
        string(name: 'UPSTREAM_BUILD_NUMBER', defaultValue: '', description: 'Upstream Jenkins build number (traceability only).')
    }

    options {
        timeout(time: 45, unit: 'MINUTES')
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Execute submission') {
            steps {
                script {
                    if (!params.SUBMIT_SCRIPT?.trim()) {
                        error 'SUBMIT_SCRIPT is empty — this job is meant to be triggered by the iOS build with the compiled script.'
                    }
                    writeFile file: 'run-testflight-submit.sh', text: params.SUBMIT_SCRIPT
                    sh 'bash run-testflight-submit.sh'
                }
            }
        }
    }

    post {
        success { echo 'TestFlight submission finished.' }
        failure { echo 'TestFlight submission FAILED. See console above.' }
        cleanup { sh 'rm -f run-testflight-submit.sh' }
    }
}
