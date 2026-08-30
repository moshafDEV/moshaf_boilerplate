#!/usr/bin/env python3
# Writes ~/jenkins-agent/builds/<job>#<build>.json so an optional menu bar /
# status app can show a live stage timeline without needing Jenkins API
# credentials — it just polls these local files. Timestamps are epoch seconds
# (not ISO strings) so the Swift side can do elapsed-time math without a
# date-format parser.
#
# One file per build rather than a single shared current-build.json: a Mac
# agent shared across multiple jobs/branches would otherwise have overlapping
# builds overwrite each other's timeline. Worse, an update matched on stage
# name alone could land on the wrong build when both happened to have a stage
# called 'Prepare'. The app prunes finished builds on its own, so nothing here
# needs to clean up.
import json
import os
import re
import sys
import time

STATUS_DIR = os.path.expanduser('~/jenkins-agent/builds')


def now():
    return time.time()


def status_file(job, build):
    # Must match buildKey() in the app's main.swift, or the two sides disagree
    # about which file a build owns and the timeline silently stops updating.
    key = re.sub(r'[^A-Za-z0-9#_-]', '_', '{}#{}'.format(job, build))
    return os.path.join(STATUS_DIR, key + '.json')


def current_status_file():
    # update/finish aren't passed job/build. Jenkins exports both into every
    # sh step, and init derived its filename from those same two values.
    return status_file(os.environ.get('JOB_NAME', ''), os.environ.get('BUILD_NUMBER', ''))


def load(path):
    with open(path) as f:
        return json.load(f)


def save(path, data):
    os.makedirs(STATUS_DIR, exist_ok=True)
    tmp = path + '.tmp'
    with open(tmp, 'w') as f:
        json.dump(data, f)
    os.replace(tmp, path)


def cmd_init(args):
    # 'Prepare' isn't one of the stage_names passed in — it runs on the
    # Jenkins controller ('built-in' node), not this Mac, so it can't write
    # here itself. But by the time any Mac-mini stage calls init(), Prepare
    # has definitely already succeeded (Jenkins wouldn't have gotten here
    # otherwise) — so it's included as an already-done first entry.
    job, build, build_url, stage_names = args[0], args[1], args[2], args[3:]
    stages = [{'name': 'Prepare', 'status': 'success', 'startedAt': None, 'endedAt': None}]
    stages += [{'name': n, 'status': 'pending', 'startedAt': None, 'endedAt': None} for n in stage_names]
    save(status_file(job, build), {
        'job': job,
        'build': build,
        'buildUrl': build_url,
        'startedAt': now(),
        'finishedAt': None,
        'result': None,
        'stages': stages,
    })


def cmd_update(args):
    stage_name, status = args
    path = current_status_file()
    # No file means init never ran for this build. The timeline is cosmetic,
    # so skip quietly instead of failing the stage that called us — the .sh
    # wrapper runs under `set -e`.
    if not os.path.exists(path):
        return
    data = load(path)
    for stage in data['stages']:
        if stage['name'] == stage_name:
            stage['status'] = status
            if status == 'running':
                stage['startedAt'] = now()
            elif status in ('success', 'failure'):
                stage['endedAt'] = now()
            break
    save(path, data)


def cmd_finish(args):
    status = args[0]
    path = current_status_file()
    if not os.path.exists(path):
        return
    data = load(path)
    data['finishedAt'] = now()
    data['result'] = status
    # Cancelling from Jenkins never runs a stage's post.failure block (ABORTED
    # is not FAILURE), so whichever stage was mid-flight would otherwise sit at
    # 'running' forever inside a build that has plainly ended. Close it out.
    terminal = 'failure' if status == 'FAILURE' else 'aborted'
    for stage in data['stages']:
        if stage['status'] == 'running':
            stage['status'] = terminal
            stage['endedAt'] = now()
    save(path, data)


COMMANDS = {'init': cmd_init, 'update': cmd_update, 'finish': cmd_finish}

if __name__ == '__main__':
    cmd, rest = sys.argv[1], sys.argv[2:]
    COMMANDS[cmd](rest)
