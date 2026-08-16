#!/bin/bash
set -euo pipefail

# A Jenkins agent container isn't sized for the JVM heap/metaspace that the
# checked-in android/gradle.properties asks for on a developer machine.
# Without this cap, the build doesn't error — it silently thrashes/hangs
# until Jenkins' durable-task heartbeat gives up (JENKINS-48300). Appended
# so the last value wins in CI only, leaving local builds untouched.
echo >> android/gradle.properties
cat <<EOF >> android/gradle.properties
org.gradle.jvmargs=-Xmx3584m -XX:MaxMetaspaceSize=1024m
org.gradle.daemon=false
org.gradle.workers.max=2
kotlin.daemon.jvmargs=-Xmx1536m
EOF

# Raw passthrough from ci/config.groovy's GRADLE_CI_EXTRA_PROPERTIES — empty
# by default, so nothing changes unless a project fills it in. Only
# $JAVA_HOME_DETECTED is resolved (plain bash substitution, not a real shell
# eval) since that's the one value config can't know ahead of time.
if [ -n "${GRADLE_CI_EXTRA_PROPERTIES:-}" ]; then
    JAVA_HOME_DETECTED=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
    RESOLVED=${GRADLE_CI_EXTRA_PROPERTIES//\$JAVA_HOME_DETECTED/$JAVA_HOME_DETECTED}
    printf '%s\n' "$RESOLVED" >> android/gradle.properties
fi
