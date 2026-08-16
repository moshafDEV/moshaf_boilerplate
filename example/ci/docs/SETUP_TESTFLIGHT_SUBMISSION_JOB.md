# Setup: TestFlight Submission Job

## Overview

The job `submit-testflight-groups-ios` ("Async TestFlight Submission") assigns an
already-uploaded TestFlight build to beta groups and, for external groups,
submits it for Beta App Review. It runs **async, off the Mac build agent**, so
the iOS build is not blocked while Apple processes the build.

All credential-bound work is compiled **on the Mac** by the upstream iOS build;
this job only executes the resulting text.

```
iOS build (Mac agent)
  ├─ Upload to TestFlight (altool)
  ├─ ci/scripts/compile-testflight-submit.sh
  │     mints the ASC JWT, resolves the app id, bakes every parameter into one
  │     self-contained script and prints it to stdout
  ├─ Trigger submit-testflight-groups-ios (wait: false), passing that text as
  │     the SUBMIT_SCRIPT parameter
  └─ Done — the iOS build does not wait for Apple

submit-testflight-groups-ios (built-in node)
  ├─ Write SUBMIT_SCRIPT to a file
  ├─ Execute it (needs only bash, curl, grep, sed — no python3, no credentials)
  └─ Poll until the build is VALID, then assign group + submit Beta App Review
```

---

## Setup in Jenkins (one-time)

### Step 1: Make sure the pipeline job exists (one-time)

The upstream iOS build triggers `Flutter/submit-testflight-groups-ios`, so this
job must exist first. In **Jenkins → the `Flutter` folder → New Item**:

1. **Item name**: `submit-testflight-groups-ios` (exact — this is the name the
   Jenkinsfile triggers)
2. **Type**: Pipeline
3. **OK**

If the job already exists, skip to Step 2 to (re)paste the definition.

### Step 2: Paste the job definition

**Configure → Pipeline:**

- **Definition**: **Pipeline script** (NOT "Pipeline script from SCM" — the job
  must not check out git or copy artifacts).
- **Script**: copy the whole block below and paste it in.
- **Save**.

> This block is a copy of `ci/jenkins-jobs/submit-testflight-groups-ios-job-definition.groovy`
> (the source of truth). If you edit one, keep the other in sync.

```groovy
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
```

The job's own `parameters { }` block defines `SUBMIT_SCRIPT` and
`UPSTREAM_BUILD_NUMBER`; any pre-existing UI parameters are reconciled away on
the first run.

### Step 3: Verify credentials (on the Mac / upstream side)

The compile step runs on the Mac and reads the App Store Connect API credentials
(the sub-job itself needs none). Verify these exist in the folder's credentials
store — see `ci/CREDENTIALS_GUIDE.md`:

- `ap1-appstore-api-key` (Secret file — the `.p8`)
- `ap1-appstore-api-key-id` (Secret text)
- `ap1-appstore-api-issuer-id` (Secret text)

(For another app such as Beautyhaul, pass its own `bhi-*` credential IDs from the
upstream Jenkinsfile instead.)

### Done

The main iOS build jobs are already wired to compile and trigger this job.

---

## How it works

**Upstream Jenkinsfile (iOS staging/production stages):**
```groovy
uploadToTestFlight('build/ios/ipa')
deferTestFlightSubmission('STAGING', env.IOS_BUNDLE_ID_STAGING, iosBuild)
```

`deferTestFlightSubmission()` (in the Jenkinsfile) runs
`ci/scripts/compile-testflight-submit.sh` under the ASC credentials, captures its
stdout (a self-contained script), and triggers this job with that text as
`SUBMIT_SCRIPT` (`wait: false`). It is gated by `TESTFLIGHT_AUTO_SUBMIT_<ENV>`.

**This job:**
- Receives the fully-compiled script as `SUBMIT_SCRIPT` (token + app id + params
  already baked in).
- Writes it to a file and runs it with `bash`.
- Needs no credentials, no ASC key, no python3 — the token is already minted and
  JSON is parsed with `grep`.

---

## Constraints

- **JWT validity is 20 min** (Apple's hard cap for an ASC JWT). The compiled
  script — including the wait-for-processing poll — must finish within that
  window. This is usually fine because the just-uploaded build is processed
  within a few minutes; if Apple processing runs long, the submission fails on
  auth and can be re-run.
- The `built-in` controller node must have `bash`, `curl`, `grep`, `sed` (it
  does). It does **not** have `python3`, which is why the compiled script avoids
  it.
- **Export compliance is required for external testing.** Every uploaded build
  must declare `ITSAppUsesNonExemptEncryption` or App Store Connect flags it
  "Missing Compliance", and assigning it to an **external** beta group then fails
  with HTTP 422 "not externally assignable" (internal testing is not blocked the
  same way). This is declared in `ios/Runner/Info.plist` **and**
  `ios/Runner/Info.dev.plist` (the dev/staging flavor uses the latter) as
  `ITSAppUsesNonExemptEncryption = false`. Keep both in sync; do not remove
  either. If a build was already uploaded without it, set export compliance
  manually in App Store Connect for that build.

---

## Monitoring

**Jenkins Dashboard → `submit-testflight-groups-ios`:**
```
#12  RUNNING
#11  SUCCESS
#10  FAILED
```
Click a build → **Console Output** for the live submission log.

---

## Troubleshooting

### `SUBMIT_SCRIPT is empty`

The job was run without the compiled script. It is meant to be triggered by the
upstream iOS build. To re-run manually, provide a `SUBMIT_SCRIPT` value.

### `required tool '<x>' not found on this agent`

The agent is missing `curl`/`grep`/`sed`. Install it, or change the job's agent
label to `mac-agent`.

### `build <n> never reached processingState VALID within the wait window`

Apple was still processing the build when the wait window (or the JWT) ran out.
Trigger a fresh iOS build, or re-run once the build shows as processed in
App Store Connect.

### Submission fails on auth (401)

The JWT expired (see the 20-min constraint). Re-run so a fresh token is minted by
the upstream build.

---

## Files

| File | Purpose |
|------|---------|
| `ci/scripts/compile-testflight-submit.sh` | Compiles the submission script on the Mac (mints JWT, resolves app id, bakes params) |
| `ci/scripts/generate-asc-jwt.py` | ES256 JWT generator, used by the compiler on the Mac |
| `ci/jenkins-jobs/submit-testflight-groups-ios-job-definition.groovy` | Sub-job definition — paste inline into Jenkins UI (Pipeline script, NOT from SCM) |
| Familia/Beautyhaul `Jenkinsfile` | `deferTestFlightSubmission()` compiles + triggers this job with `SUBMIT_SCRIPT` |
