# Guide: how to obtain/generate each credential in `ci/config.groovy`

Each `CRED_*` key in `ci/config.groovy` holds a **credential ID** — a name that must match exactly the credential created in Jenkins (**Manage Jenkins → Credentials**). This document explains how to obtain or generate the actual file or value before uploading it to Jenkins.

The credential IDs below are only examples — adjust them to your own project's naming; what matters is that they stay consistent with what is written in `ci/config.groovy`.

---

## 1. Android signing

### `CRED_ANDROID_KEYSTORE` — `.jks`/`.keystore` file

If the app has **already been released** to the Play Store: **reuse the existing keystore**, do not generate a new one — the Play Store only accepts updates signed with the same keystore as the first release.

If starting from scratch:
```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release-key
```
Keep the resulting `.jks` file safe — losing it means you can never update that app again.

Upload to Jenkins: **Kind = Secret file**, ID e.g. `<project>-android-keystore`.

### `CRED_ANDROID_KEY_PROPERTIES` — `key.properties` file

A plain text file containing:
```properties
storePassword=<keystore password>
keyPassword=<key alias password>
keyAlias=<key alias>
storeFile=<keystore file name>.jks
```
`storeFile` here must match the file name that `install-android-signing.sh` generates — that script reads `storeFile=` from this file as the source of truth for the file name.

Upload to Jenkins: **Kind = Secret file**, ID e.g. `<project>-key-properties`.

---

## 2. iOS signing (certificate + provisioning profile)

The certificate is **team-wide** (one cert can be used by many apps); the provisioning profile is **app-specific** (bound to an App ID). Staging uses an Ad Hoc cert/profile, production uses an App Store cert/profile.

### `CRED_IOS_CERT_STAGING` / `CRED_IOS_CERT_PRODUCTION` — `.p12` file

1. On the Mac, open **Keychain Access** → menu **Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority**. Fill in email and name, choose "Saved to disk". This creates a **private key** in the keychain plus a `.certSigningRequest` file.
2. Open [Apple Developer → Certificates](https://developer.apple.com/account/resources/certificates/list) → **+** → choose **Apple Distribution** → upload the `.certSigningRequest` from step 1 → download the resulting `.cer`.
3. **Double-click the `.cer`** on the same Mac (the one whose private key came from step 1) — it installs automatically as a single identity.
4. In Keychain Access, find that certificate (it must show a disclosure triangle when expanded, indicating the private key inside) → right-click → **Export** → save as `.p12` → **set a password** (do not leave it empty).

⚠️ If there is no disclosure triangle on export, or importing into Jenkins only reports **"1 certificate imported"** (without "identity"/"key"), the private key was not included — repeat from step 1 on the correct Mac.

Upload to Jenkins: **Kind = Secret file**, ID e.g. `<team>-ios-distribution-cert-staging` (staging) / `<project>-ios-appstore-cert` (production).

### `CRED_IOS_CERT_PASSWORD_STAGING` / `_PRODUCTION` — string

The password you set when exporting the `.p12` above. Upload to Jenkins: **Kind = Secret text**.

### `CRED_IOS_PROFILE_STAGING` / `_PRODUCTION` — `.mobileprovision` file

At [Apple Developer → Profiles](https://developer.apple.com/account/resources/profiles/list) → **+**:
- **Staging** → choose type **Ad Hoc**, the staging bundle ID App ID, the certificate from the previous step, and the devices allowed to install → download.
- **Production** → choose type **App Store**, the production bundle ID App ID → download.

Upload to Jenkins: **Kind = Secret file**.

If the profile is regenerated (e.g. after adding a new device, or a new capability such as Associated Domains), **download it again** and **replace** the credential file in Jenkins — the old file does not update automatically.

### `CRED_IOS_EXTRA_PROFILES_STAGING` / `_PRODUCTION` — `.zip` file (optional)

Only needed if the app has an **App Extension** (Notification Service Extension, Share Extension, etc.) — each extension needs its own profile because it has its own bundle ID (`com.app.main.NotificationService`, etc.). If the app has no extension, leave this empty.

If needed: download each extension profile (App Store/Ad Hoc per environment) from the Apple Developer portal, compress them all into one `.zip`, and upload as **Secret file**.

---

## 3. Shared credentials (used by every project)

### `CRED_IOS_KEYCHAIN_PASSWORD` — string

Not obtained from anywhere — this is just the password for the temporary keychain that CI creates on every build (`ci.keychain`) and deletes again once the build finishes. **Set it to anything**, as long as Jenkins consistently uses the same value.

### `CRED_BUILDFLIGHT_API_KEY` — string

Only relevant if you use an internal OTA/beta-distribution service (`BUILDFLIGHT_API_URL` in `ci/config.groovy`) — this repo's setup assumes one exists, but it's an org-internal tool, not a public product, so you may not have an equivalent. If you don't, set the `*_DISTRIBUTION` flags in `ci/config.groovy` to `'store'`/`'testflight'` and skip this credential entirely. If you do have one, get the API key from its dashboard, usually on the Settings/API page for your account/organization.

### `CRED_APPSTORE_API_KEY` (`.p8`) + `CRED_APPSTORE_API_KEY_ID` + `CRED_APPSTORE_API_ISSUER_ID`

At [App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api):
1. Click **+** to generate a new key, give it a name, role at least **App Manager**.
2. **Download the `.p8` file NOW** — Apple only allows the download **once**; it cannot be re-downloaded later.
3. Note the **Key ID** (the column in the key table) and the **Issuer ID** (above the table, the same for all keys).

Upload to Jenkins:
- `.p8` → **Kind = Secret file**, ID e.g. `<team>-appstore-api-key`
- Key ID → **Kind = Secret text**, ID e.g. `<team>-appstore-api-key-id`
- Issuer ID → **Kind = Secret text**, ID e.g. `<team>-appstore-api-issuer-id`

This key is **team-wide**, so if another project already has it on the same Jenkins, there's no need to generate a new one — just reuse the same credential ID in `config.groovy`.

### `CRED_PLAYSTORE_SERVICE_ACCOUNT` — `.json` file

Used to upload the production `.aab` to the Play Console (e.g. to the Internal testing track) via the Play Developer Publishing API — not a Gradle plugin, so it never touches the `android/` files.

1. Create/select a **Google Cloud Project**, then enable the **Google Play Developer API**.
2. In **Google Cloud Console → IAM & Admin → Service Accounts → Create service account**.
3. Copy the service account email, e.g. `play-ci@my-project.iam.gserviceaccount.com`.
4. In **Google Play Console → Users and permissions → Invite new users**, enter that service account email and grant it access to the app you deploy.
5. If the pipeline only deploys to **Internal / Closed / Open testing**, the **"Release apps to testing tracks"** permission is exactly right and does not grant production-publish rights.
6. Then **Google Cloud Console → Service Accounts → the service account → Keys → Add key → Create new key → JSON**. The `.json` downloads immediately and **cannot be re-downloaded** afterwards.

⚠️ This JSON file has direct access to your Play Console app — treat it like a password; do not put it anywhere other than a Jenkins credential.

Upload to Jenkins: **Kind = Secret file**, ID e.g. `<team>-playstore-service-account`.

---

## How to upload to Jenkins (all credential types)

1. **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**
2. Choose **Kind**:
   - **Secret file** — for `.jks`, `.p12`, `.mobileprovision`, `.zip`, `.p8`, `.json`
   - **Secret text** — for passwords/strings/IDs
3. **ID** — enter it **exactly** as written in `ci/config.groovy`. Even a small difference makes Jenkins error "credential not found" at build time.
4. Save.

To **update** a credential (e.g. a new cert or profile): open the existing credential → **Update** → upload the new file / enter the new value. Do not change the ID, so `config.groovy` does not have to change too.
