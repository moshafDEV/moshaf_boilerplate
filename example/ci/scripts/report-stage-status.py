#!/usr/bin/env python3
# Writes ~/jenkins-agent/current-build.json so an optional menu bar / status
# app can show a live stage timeline without needing Jenkins API
# credentials — it just polls this local file. Timestamps are epoch seconds
# (not ISO strings) so the Swift side can do elapsed-time math without a
# date-format parser.
import json
import os
import sys
import time

STATUS_FILE = os.path.expanduser('~/jenkins-agent/current-build.json')


def now():
    return time.time()


def load():
    with open(STATUS_FILE) as f:
        return json.load(f)


def save(data):
    tmp = STATUS_FILE + '.tmp'
    with open(tmp, 'w') as f:
        json.dump(data, f)
    os.replace(tmp, STATUS_FILE)


def cmd_init(args):
    # 'Prepare' isn't one of the stage_names passed in — it runs on the
    # Jenkins controller ('built-in' node), not this Mac, so it can't write
    # here itself. But by the time any Mac-mini stage calls init(), Prepare
    # has definitely already succeeded (Jenkins wouldn't have gotten here
    # otherwise) — so it's included as an already-done first entry.
    job, build, build_url, stage_names = args[0], args[1], args[2], args[3:]
    stages = [{'name': 'Prepare', 'status': 'success', 'startedAt': None, 'endedAt': None}]
    stages += [{'name': n, 'status': 'pending', 'startedAt': None, 'endedAt': None} for n in stage_names]
    save({
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
    data = load()
    for stage in data['stages']:
        if stage['name'] == stage_name:
            stage['status'] = status
            if status == 'running':
                stage['startedAt'] = now()
            elif status in ('success', 'failure'):
                stage['endedAt'] = now()
            break
    save(data)


def cmd_finish(args):
    status = args[0]
    data = load()
    data['finishedAt'] = now()
    data['result'] = status
    save(data)


COMMANDS = {'init': cmd_init, 'update': cmd_update, 'finish': cmd_finish}

if __name__ == '__main__':
    cmd, rest = sys.argv[1], sys.argv[2:]
    COMMANDS[cmd](rest)
