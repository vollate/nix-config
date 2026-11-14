"""Serialized maintenance runners and read-only textfile collection."""
import contextlib
import fcntl
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import time

ERRORS = ('read_errors', 'csum_errors', 'verify_errors', 'super_errors',
          'malloc_errors', 'uncorrectable_errors', 'unverified_errors', 'corrected_errors')
RESULTS = ('passed', 'failed', 'aborted', 'interrupted', 'unknown')


def command(args):
    return subprocess.run(args, capture_output=True, text=True, timeout=120,
                          env={**os.environ, 'LC_ALL': 'C'})


def checked(args):
    p = command(args)
    if p.returncode:
        raise RuntimeError(f'{args[0]}: {p.stderr}')
    return p.stdout


def smart_result(code, protocol):
    if protocol == 'ata':
        return {0: 'passed', 1: 'aborted', 2: 'interrupted',
                **dict.fromkeys(range(3, 9), 'failed')}.get(code >> 4, 'unknown')
    return {0: 'passed', 1: 'aborted', 2: 'interrupted', 3: 'interrupted',
            4: 'aborted', 5: 'failed', 6: 'failed', 7: 'failed',
            8: 'aborted', 9: 'aborted'}.get(code, 'unknown')


def parse_smart(data, protocol):
    if data['smartctl']['exit_status'] & 7:
        raise ValueError('SMART command/access failure')
    if data['device']['protocol'].lower() != protocol:
        raise ValueError('unexpected SMART protocol')
    identity = data['serial_number']
    if not identity:
        raise ValueError('missing serial')
    if protocol == 'ata':
        status = data['ata_smart_data']['self_test']['status']['value'] >> 4
        if status not in (*range(9), 15):
            raise ValueError('unknown ATA execution status')
        running = status == 15
        logs = data['ata_smart_self_test_log']
        log = logs.get('extended', logs.get('standard'))
        if log is None or 'revision' not in log:
            raise ValueError('missing ATA self-test log')
        entries = [e for e in log.get('table', []) if e['type']['value'] in (2, 130)
                   and e['status']['value'] >> 4 != 15]
        outcomes = [smart_result(e['status']['value'], protocol) for e in entries]
    else:
        log = data['nvme_self_test_log']
        operation = log['current_self_test_operation']['value']
        if operation not in (0, 1, 2, 14):
            raise ValueError('unknown NVMe operation')
        running = operation != 0
        entries = [e for e in log.get('table', []) if e['self_test_code']['value'] == 2
                   and e['self_test_result']['value'] != 15]
        outcomes = [smart_result(e['self_test_result']['value'], protocol) for e in entries]
    # Newest decisive extended result wins; aborted/short tests cannot erase failure.
    decisive_index = next((i for i, x in enumerate(outcomes) if x in ('passed', 'failed')), None)
    decisive = outcomes[decisive_index] if decisive_index is not None else None
    def token(entry):
        # Positions and translated descriptions are not stable log identities.
        if protocol == 'ata':
            fields = [entry['type']['value'], entry['status']['value'],
                      entry['lifetime_hours'], entry.get('lba')]
        else:
            fields = [entry['self_test_code']['value'], entry['self_test_result']['value'],
                      entry['power_on_hours'], entry.get('nsid'), entry.get('segment'), entry.get('lba')]
        return json.dumps(fields, sort_keys=True)
    return dict(identity=identity, running=int(running), result=outcomes[0] if outcomes else 'unknown',
                decisive=decisive, decisive_token=token(entries[decisive_index]) if decisive_index is not None else None,
                token=token(entries[0]) if entries else None)


def parse_scrub(text):
    uuid = re.search(r'^UUID:\s+(\S+)', text, re.M)
    if not uuid:
        raise ValueError('missing scrub UUID')
    if 'no stats available' in text:
        return dict(identity=uuid[1], running=0, token=None, finished=False, errors={})
    status = re.search(r'^Status:\s+(\S+)', text, re.M)
    start = re.search(r'^Scrub (?:started|resumed):\s+(.+)', text, re.M)
    if not status or not start or status[1] not in ('running', 'finished', 'aborted', 'interrupted'):
        raise ValueError('unrecognized scrub status')
    errors = {key: int(re.search(r'^\s*' + key + r':\s+(\d+)', text, re.M)[1]) for key in ERRORS}
    return dict(identity=uuid[1], running=int(status[1] == 'running'), token=start[1],
                finished=status[1] == 'finished', errors=errors)


def query(kind, target):
    if kind == 'selftest':
        p = command(['smartctl', '-j', '-i', '-c', '-l', 'selftest', target['device']])
        return parse_smart(json.loads(p.stdout), target['protocol'])
    mount = target['mountPoint']
    fs = json.loads(checked(['findmnt', '--json', '--mountpoint', mount, '-o', 'TARGET,FSTYPE,UUID']))['filesystems']
    if len(fs) != 1 or fs[0]['fstype'] != 'btrfs' or not fs[0]['uuid']:
        raise ValueError('target is not a mounted Btrfs filesystem')
    result = parse_scrub(checked(['btrfs', 'scrub', 'status', '-R', mount]))
    if result['identity'] != fs[0]['uuid']:
        raise ValueError('scrub UUID differs from mounted filesystem')
    return result


def atomic(path, text, mode=0o600):
    fd, name = tempfile.mkstemp(dir=path.parent, prefix='.pending-')
    try:
        with os.fdopen(fd, 'w') as f:
            f.write(text)
            f.flush()
            os.fsync(f.fileno())
            os.fchmod(f.fileno(), mode)
        os.replace(name, path)
        directory = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)
    finally:
        if os.path.exists(name):
            os.unlink(name)


@contextlib.contextmanager
def lock(path):
    with open(path, 'a') as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        yield


def initial(identity=None):
    return dict(identity=identity, monitoring_since_seconds=time.time(),
                last_success_timestamp_seconds=0, last_completion_timestamp_seconds=0,
                running=0, collection_success=0, last_poll_timestamp_seconds=0,
                result='unknown', failure=0, errors={})


def observe(state, obs, kind):
    now = time.time()
    if state['identity'] != obs['identity']:
        state = initial(obs['identity'])
    changed = 'token' in state and state['token'] != obs['token']
    if kind == 'selftest':
        state['result'] = obs['result']
        new_decisive = ('decisive_token' in state and obs['decisive_token'] is not None
                        and state['decisive_token'] != obs['decisive_token'])
        if obs['decisive'] == 'failed':
            state['failure'] = 1
        elif obs['decisive'] == 'passed' and ('token' not in state or new_decisive):
            state['failure'] = 0
        if changed and obs['token'] is not None:
            state['last_completion_timestamp_seconds'] = now
        if new_decisive and obs['decisive'] == 'passed':
            state['last_success_timestamp_seconds'] = now
        state['decisive_token'] = obs['decisive_token']
    elif obs['finished']:
        state['errors'] = obs['errors']
        if changed or state['running']:
            state['last_completion_timestamp_seconds'] = now
            if not any(obs['errors'].values()):
                state['last_success_timestamp_seconds'] = now
    if kind == 'selftest' or obs['finished'] or 'token' not in state:
        state['token'] = obs['token']
    state.update(running=obs['running'], collection_success=1,
                 last_poll_timestamp_seconds=now)
    return state


def metrics(states):
    lines = []
    declared = set()
    def emit(name, labels, value):
        if name not in declared:
            lines.extend(['# HELP disk_maintenance_' + name + ' Disk maintenance ' + name.replace('_', ' ') + '.',
                          '# TYPE disk_maintenance_' + name + ' gauge'])
            declared.add(name)
        lines.append('disk_maintenance_' + name + '{' + ','.join(
            k + '=' + json.dumps(v) for k, v in labels.items()) + '} ' + str(value))
    for key, s in states.items():
        kind, target = key.split(':', 1)
        labels = dict(kind=kind, target=target)
        emit('expected', labels, 1)
        for name in ('monitoring_since_seconds', 'last_success_timestamp_seconds',
                     'last_completion_timestamp_seconds', 'running', 'collection_success',
                     'last_poll_timestamp_seconds'):
            emit(name, labels, s[name])
        if kind == 'scrub':
            for error, value in s['errors'].items():
                emit('scrub_errors', dict(target=target, type=error), value)
        else:
            emit('selftest_failure', dict(target=target), s['failure'])
            for result in RESULTS:
                emit('selftest_last_result', dict(target=target, result=result), int(s['result'] == result))
    return '\n'.join(lines) + '\n'


class Maintenance:
    def __init__(self, config):
        self.cfg = config
        self.root = Path(config.get('stateDirectory', '/var/lib/disk-maintenance'))
        self.targets = {**{'scrub:' + k: v for k, v in config['scrubs'].items()},
                        **{'selftest:' + k: v for k, v in config['selfTests'].items()}}

    def poll(self, fixtures=None):
        self.root.mkdir(mode=0o711, parents=True, exist_ok=True)
        self.root.chmod(0o711)
        with lock(self.root / 'state.lock'):
            path = self.root / 'state.json'
            states = json.loads(path.read_text()) if path.exists() else {}
            states = {k: states.get(k, initial()) for k in self.targets}
            failed = False
            for key, target in self.targets.items():
                kind = key.split(':')[0]
                configured = target.get('device', target.get('mountPoint'))
                if states[key].get('configured') != configured:
                    states[key] = initial()
                try:
                    if fixtures is None:
                        obs = query(kind, target)
                    elif kind == 'scrub':
                        obs = parse_scrub(Path(fixtures[key]).read_text())
                    else:
                        obs = parse_smart(json.loads(Path(fixtures[key]).read_text()), target['protocol'])
                    obs['identity'] = configured + ':' + obs['identity']
                    states[key] = observe(states[key], obs, kind)
                except Exception as e:
                    print(f'{key}: {e}', file=sys.stderr)
                    states[key]['collection_success'] = 0
                    failed = True
                states[key]['configured'] = configured
            atomic(path, json.dumps(states))
            output = self.root / 'textfile'
            output.mkdir(mode=0o755, exist_ok=True)
            output.chmod(0o755)
            atomic(output / 'maintenance.prom', metrics(states), 0o644)
            if failed:
                raise RuntimeError('status collection failed')
            return states

    def wait_idle(self):
        # Manual jobs bypassing this coordinator cannot be excluded by flock.
        while True:
            observations = [query(k.split(':')[0], t) for k, t in self.targets.items()]
            if not any(o['running'] for o in observations):
                return
            time.sleep(self.cfg['pollInterval'])

    def run(self, kind, name):
        key = kind + ':' + name
        target = self.targets[key]
        with lock(self.cfg['lockFile']):
            self.wait_idle()
            before = self.poll()[key]
            if kind == 'scrub':
                mount = target['mountPoint']
                proc = None
                def stop(signum, frame):
                    raise InterruptedError('scrub runner stopped')
                signal.signal(signal.SIGTERM, stop)
                signal.signal(signal.SIGINT, stop)
                try:
                    proc = subprocess.Popen(['btrfs', 'scrub', 'start', '-B', mount])
                    rc = proc.wait()
                    obs = query(kind, target)
                    if (rc not in (0, 3) or not obs['finished'] or obs['token'] == before['token']
                            or mount + ':' + obs['identity'] != before['identity']):
                        raise RuntimeError('scrub did not produce a new completed result')
                    self.poll()
                finally:
                    if proc is not None and proc.poll() is None:
                        checked(['btrfs', 'scrub', 'cancel', mount])
                        proc.wait(timeout=120)
            else:
                p = command(['smartctl', '-j', '-t', 'long', target['device']])
                data = json.loads(p.stdout)
                if data['smartctl']['exit_status'] & 7:
                    raise RuntimeError('could not start extended test')
                deadline = time.monotonic() + target['maxDuration']
                while time.monotonic() < deadline:
                    time.sleep(self.cfg['pollInterval'])
                    state = self.poll()[key]
                    if state['identity'] != before['identity']:
                        raise RuntimeError('device identity changed during test')
                    if not state['running']:
                        if state['token'] == before['token'] or state['result'] not in ('passed', 'failed'):
                            raise RuntimeError('no new completed extended test')
                        return
                raise RuntimeError('extended test exceeded maxDuration; hardware test not aborted')


def main():
    cfg = json.loads(Path(sys.argv[1]).read_text())
    app = Maintenance(cfg)
    mode = sys.argv[2]
    if mode == 'status':
        app.poll()
    elif mode == 'fixtures':
        app.poll(json.loads(Path(sys.argv[3]).read_text()))
    elif mode == 'wait-idle':
        app.wait_idle()
    elif mode in ('scrub', 'selftest'):
        app.run(mode, sys.argv[3])
    else:
        raise ValueError('unknown command')


if __name__ == '__main__':
    main()
