// Single file to edit when copying this Jenkins setup to a different
// Flutter project. Jenkinsfile and ci/scripts/*.sh stay untouched — they
// just read whatever is returned here.
return [
    // ================================================================
    // CI infrastructure — which agent(s), Docker vs native, workspace mode
    // ================================================================
    // TODO: replace with your Jenkins node label (Manage Jenkins → Nodes).
    IOS_AGENT_LABEL: 'your-mac-agent-label', // Jenkins node label running the Mac agent

    // Prepare (the very first stage) can't use this — it's what reads this
    // file in the first place, so its own agent is a hardcoded 'built-in'.
    // Every stage after Prepare uses this instead.
    LINUX_AGENT_LABEL: 'your-mac-agent-label',

    // 'docker' — Android builds run in FLUTTER_DOCKER_IMAGE.
    // 'native' — runs `fvm flutter`/`fvm dart` directly on the agent, no
    // Docker. Use this when LINUX_AGENT_LABEL == IOS_AGENT_LABEL (Android +
    // iOS sharing one Mac) so Docker Desktop isn't one more thing to run.
    ANDROID_BUILD_MODE: 'native',

    // Only takes effect when ANDROID_BUILD_MODE is 'native' AND both agent
    // labels above point at the same Mac. 'false' (default) — every run
    // gets a fresh clone. 'true' — clone once, ever; every later run just
    // does an incremental `checkout scm` (a git fetch, not a full clone),
    // because the workspace's .git is never wiped between runs — only
    // build/ output gets deleted (see cleanBuildArtifacts() in Jenkinsfile).
    PRESERVE_WORKSPACE_NATIVE: 'true',

    FLUTTER_DOCKER_IMAGE: 'ghcr.io/cirruslabs/flutter:3.38.5', // must match .fvmrc; unused in native mode
    FLUTTER_DOCKER_ARGS : '-v ProjectName-pub-cache:/root/.pub-cache -v ProjectName-gradle-cache:/root/.gradle/caches', // unused in native mode

    // ================================================================
    // Android signing — Jenkins credential IDs
    // ================================================================
    CRED_ANDROID_KEYSTORE      : 'ProjectName-android-keystore',   // .jks / .keystore file credential
    CRED_ANDROID_KEY_PROPERTIES: 'ProjectName-key-properties',     // key.properties file credential

    // ================================================================
    // iOS signing — staging ships Ad Hoc, production ships App
    // Store/TestFlight, so separate Apple certs per environment. The
    // distribution CERTIFICATE is team-wide (shared across projects); the
    // PROFILE is app-specific (tied to one App ID + device list).
    // ================================================================
    CRED_IOS_CERT_STAGING             : 'ProjectName-ios-distribution-cert',          // .p12 file credential
    CRED_IOS_CERT_PASSWORD_STAGING    : 'ProjectName-ios-distribution-cert-password', // string credential
    CRED_IOS_PROFILE_STAGING          : 'ProjectName-ios-adhoc-profile',         // .mobileprovision file credential (Ad Hoc)
    CRED_IOS_PROFILE_STAGING_TESTFLIGHT: 'ProjectName-ios-appstore-staging-profile',     // .mobileprovision file credential (App Store, used only if IOS_STAGING_DISTRIBUTION is 'testflight' or 'both')
    CRED_IOS_EXTRA_PROFILES_STAGING   : '', // .zip of extra .mobileprovision files (Ad Hoc) — blank if none
    CRED_IOS_EXTRA_PROFILES_STAGING_TESTFLIGHT: '', // .zip of extra .mobileprovision files (App Store, for TestFlight) — blank if none

    CRED_IOS_CERT_PRODUCTION          : 'ProjectName-ios-distribution-cert',          // .p12 file credential
    CRED_IOS_CERT_PASSWORD_PRODUCTION : 'ProjectName-ios-distribution-cert-password', // string credential
    CRED_IOS_PROFILE_PRODUCTION       : 'ProjectName-ios-appstore-profile',       // .mobileprovision file credential
    CRED_IOS_EXTRA_PROFILES_PRODUCTION: '', // same idea as staging — .zip, blank if none

    // ================================================================
    // Shared credentials — same across every project on this Jenkins.
    // Unlike everything above (per-project), these three are meant to be
    // the SAME credential ID reused by every Flutter project on your
    // Jenkins — set them once here, then again identically in every other
    // project's config.groovy, not derived from ProjectName.
    // ================================================================
    // TODO: replace 'yourorg' with your own org/team prefix.
    CRED_IOS_KEYCHAIN_PASSWORD: 'yourorg-ios-ci-keychain-password', // (SAME) string credential; unlocks the throwaway per-build CI keychain
    CRED_BUILDFLIGHT_API_KEY  : 'buildflight-api-key',               // string credential — only needed if you use the buildflight OTA feature below

    // App Store Connect API key — used only to upload to TestFlight and
    // manage beta groups. Role "App Manager" or higher, doesn't need Admin.
    // Not needed at all if IOS_PRODUCTION_DISTRIBUTION below is 'buildflight'.
    // Team-wide (one ASC API key per Apple Developer team), not per-project.
    CRED_APPSTORE_API_KEY      : 'yourorg-appstore-api-key',       // .p8 file credential
    CRED_APPSTORE_API_KEY_ID   : 'yourorg-appstore-api-key-id',    // string credential
    CRED_APPSTORE_API_ISSUER_ID: 'yourorg-appstore-api-issuer-id', // string credential

    // Google Play service account — used only to upload the production .aab
    // to a Play Console testing track. Needs "Release apps to testing
    // tracks" permission in Play Console, nothing more. Not needed at all
    // if ANDROID_PRODUCTION_DISTRIBUTION below is 'buildflight'. Usually one
    // service account per Play Console developer account, not per-app.
    CRED_PLAYSTORE_SERVICE_ACCOUNT: 'yourorg-playstore-service-account', // .json file credential

    // ================================================================
    // Distribution channel — how staging/production builds get shipped
    // ================================================================
    // 'adhoc'      — Ad Hoc + buildflight (default).
    // 'testflight' — App Store-signed build, TestFlight only, no buildflight.
    // 'both'       — does both. Slower: two full iOS builds, since
    //                `flutter build ipa` always writes to the same
    //                build/ios/ipa/ regardless of export options, so the Ad
    //                Hoc one must upload before the second build overwrites it.
    // 'testflight'/'both' need an App Store Connect record + an App Store
    // (not Ad Hoc) profile for IOS_EXPORT_OPTIONS_STAGING_TESTFLIGHT below —
    // neither exists just from setting this flag.
    IOS_STAGING_DISTRIBUTION             : 'adhoc',
    IOS_EXPORT_OPTIONS_STAGING_TESTFLIGHT: 'ios/ExportOptionsStagingTestFlight.plist', // .plist

    // Production distribution.
    // 'store'       — (default) ships through Play Store / App Store,
    //                 optionally also Play Internal testing / TestFlight
    //                 (the 4 flags right below).
    // 'buildflight' — skips the store entirely. For Enterprise/In-House
    //                 apps that are never public — ships a plain .apk/.ipa
    //                 straight to buildflight, same as staging's Ad Hoc
    //                 build already does. In this mode, CRED_APPSTORE_*
    //                 and CRED_PLAYSTORE_SERVICE_ACCOUNT below are never
    //                 read — only CRED_BUILDFLIGHT_API_KEY is needed.
    ANDROID_PRODUCTION_DISTRIBUTION: 'store',
    IOS_PRODUCTION_DISTRIBUTION    : 'store',

    // Both flags below are ignored when the matching *_PRODUCTION_DISTRIBUTION
    // above is 'buildflight' (TestFlight/Play Internal don't apply then).
    IOS_PRODUCTION_TESTFLIGHT_ENABLED: 'false', // 'true' to also upload the production build to TestFlight
    // 'true' to also upload the production .aab to Play Console's Internal
    // testing track. Track name is fixed to 'internal' in the Jenkinsfile —
    // not worth a config key for just one value.
    ANDROID_INTERNAL_TESTING_ENABLED: 'false',

    // ================================================================
    // TestFlight beta group auto-submit — off by default. Uploading alone
    // doesn't make a build available to testers; a group ID here does.
    // Internal group = instant, no review. External group = also submits
    // Beta App Review (not instant). Blank a group ID to skip it. Find IDs
    // in App Store Connect → app → TestFlight → group → its URL.
    // ================================================================
    TESTFLIGHT_AUTO_SUBMIT_STAGING         : 'false',
    TESTFLIGHT_INTERNAL_GROUP_ID_STAGING   : '',
    TESTFLIGHT_EXTERNAL_GROUP_ID_STAGING   : '',

    TESTFLIGHT_AUTO_SUBMIT_PRODUCTION      : 'false',
    TESTFLIGHT_INTERNAL_GROUP_ID_PRODUCTION: '',
    TESTFLIGHT_EXTERNAL_GROUP_ID_PRODUCTION: '',

    // ================================================================
    // App identity — keep these in sync with flavorizr.yaml's applicationId
    // /bundleId for the matching flavor (dev ↔ *_STAGING, prod ↔ *_PRODUCTION).
    // ================================================================
    ANDROID_BUNDLE_ID_STAGING   : 'com.example.ProjectName.dev',
    ANDROID_BUNDLE_ID_PRODUCTION: 'com.example.ProjectName',
    IOS_BUNDLE_ID_STAGING       : 'com.example.ProjectName.dev',
    IOS_BUNDLE_ID_PRODUCTION    : 'com.example.ProjectName',

    // ================================================================
    // Flavor / entrypoint / env file per build
    // ================================================================
    ANDROID_ENV_FILE_STAGING     : '.env.dev',           // .env
    ANDROID_FLAVOR_STAGING       : 'dev',
    ANDROID_ENTRYPOINT_STAGING   : 'lib/main_dev.dart',  // .dart
    ANDROID_ENV_FILE_PRODUCTION  : '.env.prod',          // .env
    ANDROID_FLAVOR_PRODUCTION    : 'prod',
    ANDROID_ENTRYPOINT_PRODUCTION: 'lib/main_prod.dart', // .dart

    IOS_ENV_FILE_STAGING         : '.env.dev',                         // .env
    IOS_FLAVOR_STAGING           : 'dev',
    IOS_ENTRYPOINT_STAGING       : 'lib/main_dev.dart',                // .dart
    IOS_EXPORT_OPTIONS_STAGING   : 'ios/ExportOptionsStaging.plist',   // .plist

    IOS_ENV_FILE_PRODUCTION      : '.env.prod',                        // .env
    IOS_FLAVOR_PRODUCTION        : 'prod',
    IOS_ENTRYPOINT_PRODUCTION    : 'lib/main_prod.dart',               // .dart
    IOS_EXPORT_OPTIONS_PRODUCTION: 'ios/ExportOptionsProduction.plist', // .plist

    // ================================================================
    // buildflight — this org's own internal OTA/beta-distribution service
    // (not a public third-party product). If you don't have an equivalent,
    // set both *_DISTRIBUTION flags above to 'store'/'testflight' and you
    // can ignore BUILDFLIGHT_API_URL, CRED_BUILDFLIGHT_API_KEY, and the
    // ci/scripts/buildflight-*.sh scripts entirely — they're only called
    // when a distribution mode above is 'adhoc'/'buildflight'.
    // ================================================================
    BUILDFLIGHT_API_URL     : 'https://buildflight.example.com', // TODO: your own OTA service's API base URL, if any
    BUILDFLIGHT_APK_FILENAME: 'ProjectName.apk', // .apk — what testers see in the OTA listing
    BUILDFLIGHT_IPA_FILENAME: 'ProjectName.ipa', // .ipa

    // ================================================================
    // iOS provisioning profile install filenames — different profile per
    // environment, so installIosSigning() needs a different destination
    // filename too (under ~/Library/MobileDevice/Provisioning Profiles/).
    // Staging can have two variants: Ad Hoc (default) and App Store (if 'both'
    // mode), each installed to a separate filename to avoid overwrites.
    // ================================================================
    IOS_PROVISIONING_PROFILE_FILENAME_STAGING           : 'ProjectName_Ad_Hoc_Staging.mobileprovision',       // .mobileprovision (Ad Hoc)
    IOS_PROVISIONING_PROFILE_FILENAME_STAGING_TESTFLIGHT: 'ProjectName_Appstore_Staging.mobileprovision',    // .mobileprovision (App Store, used if IOS_STAGING_DISTRIBUTION is 'testflight' or 'both')

    IOS_PROVISIONING_PROFILE_FILENAME_PRODUCTION        : 'ProjectName_Appstore_Production.mobileprovision', // .mobileprovision

    // ================================================================
    // Gradle/CI extras — raw lines appended to android/gradle.properties.
    // Blank by default. $JAVA_HOME_DETECTED is available if needed, e.g.:
    // GRADLE_CI_EXTRA_PROPERTIES: 'org.gradle.java.home=$JAVA_HOME_DETECTED',
    // ================================================================
    GRADLE_CI_EXTRA_PROPERTIES: '',
]
