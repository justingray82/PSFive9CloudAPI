#!/usr/bin/env python3
"""Regenerate skills/five9-cloud-scripting/references/functions.md from the module source.

Run from the repository root:   python skills/tools/generate_function_reference.py

Reads every top-level *.ps1, takes the command name from the `function` line (not the
file name), and records parameters, effect, and what the function outputs. Output
detection is heuristic; entries in OUTPUT_OVERRIDES win. Review the diff after running.
"""
import re, os, glob, datetime

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DEST = os.path.join(ROOT, 'skills', 'five9-cloud-scripting', 'references', 'functions.md')

OUTPUT_OVERRIDES = {
    'Get-Five9CloudServiceAccounts': 'list of service accounts',
    'Get-Five9CloudEmailConfigurations': 'one configuration (with -EmailConfigurationId) or a list of configurations',
    'Get-Five9CloudInboundCampaignDetails': 'one combined object per campaign (all tabs); -Raw for untouched API responses',
    'Get-Five9CloudOutboundCampaignDetails': 'one combined object per campaign (all tabs); -Raw for untouched API responses',
    'Get-Five9CloudCampaignProfileDetails': 'one combined object per profile; -Raw for untouched API responses',
    'Get-Five9CloudCircleAttributeDetails': 'names (strings)',
    'Get-Five9CloudUserACLDetails': 'entries for the chosen -Scope (names for circles); all users when no user is given',
    'Get-Five9CloudDomainVerintPackages': 'list of packages',
    'Get-Five9CloudNumberCredits': 'one object of credit counts (e.g. DID_AVAILABLE)',
    'Get-Five9CloudNumberInventory': 'one row per area code: AreaCode, State, Available, NumberType, Country',
    'Get-Five9CloudJwtClaims': 'decoded token claims (internal)',
    'Get-Five9CloudAuthHeader': 'internal; never print (contains the access token)',
    'Add-Five9CloudPhoneNumber': 'claim result after polling; the bulkClaimId with -NoWait; $false on failure',
    'New-Five9CloudNumberOrder': 'object with NumberOrderId and Status; $false on failure',
    'New-Five9CloudUser': 'nothing, success or failure: verify by re-reading',
    'Set-Five9CloudUserStatus': 'nothing, success or failure: verify by re-reading',
    'Connect-Five9Cloud': 'nothing; sets $global:Five9 (empty on failure)',
    'Test-Five9CloudConnection': '$true or $false',
}
INTERNAL = {'Get-Five9CloudAuthHeader','Get-Five9CloudJwtClaims','Invoke-Five9CloudApi','Invoke-Five9CloudAuth',
            'Invoke-Five9CloudOAuth','Invoke-Five9CloudPagedApi','Set-Five9CloudQueryUri','Set-Five9CloudToken'}
AREAS = [
    ('Connection', r'^(Connect|Test)-'),
    ('Phone numbers, ANI groups, and caller ID', r'AniGroup|AniId|PhoneNumber|NumberCredits|NumberInventory|NumberOrder|DomainNumbers|CampaignNumber|UserDID|ProfileAniGroup'),
    ('Campaigns, campaign profiles, scripts, and prompts', r'Campaign|Script|Prompt|Connector|Disposition'),
    ('Users and access', r'User|CannedReport|Circle|Permission|ReasonCode|Application|IdpPolicy|IdPPolicy|MFA|SkillUsers|SkillId'),
    ('Domain settings, tags, schedules, email, digital assistance, audit log', r'.'),
]

def params_of(txt):
    out, seen = [], set()
    pat = r"((?:\[(?:Parameter|ValidateSet|ValidateRange|Alias)\([^\]]*\)\]\s*)*)\[(string|int|bool|switch|long|datetime|string\[\]|int\[\]|object|object\[\]|hashtable|array|PSObject)\]\s*\$([A-Za-z][A-Za-z0-9_]*)"
    for m in re.finditer(pat, txt):
        attrs, typ, pn = m.groups()
        if pn in seen or (pn[0].islower() and len(pn) <= 3) or pn in ('page', 'item', 'credits', 'claims'):
            continue
        seen.add(pn)
        s = pn
        vs = re.search(r"ValidateSet\(([^)]*)\)", attrs)
        if vs: s += " (" + vs.group(1).replace("'", "").replace('"', '').replace(" ", "").replace(",", "\\|") + ")"
        vr = re.search(r"ValidateRange\(([^)]*)\)", attrs)
        if vr: s += " (" + vr.group(1).replace(" ", "").replace(",", "-") + ")"
        if 'Mandatory' in attrs: s += "*"
        if typ == 'switch': s += " [switch]"
        elif typ == 'bool': s += " [bool]"
        elif typ.endswith('[]'): s += " [array]"
        out.append(s)
    for m in re.finditer(r"New-DynParam '([A-Za-z]+)'", txt):
        if m.group(1) not in seen:
            seen.add(m.group(1)); out.append(m.group(1) + " (dynamic)")
    return out

def effect(n):
    v = n.split('-')[0]
    if n in ('Add-Five9CloudPhoneNumber', 'New-Five9CloudNumberOrder'): return 'WRITE, uses credits'
    if n == 'Remove-Five9CloudPhoneNumbers': return 'DESTRUCTIVE, releases numbers'
    if n == 'Set-Five9CloudUserStatus': return 'WRITE, deactivation is disruptive'
    if v in ('Remove', 'Reset'): return 'DESTRUCTIVE'
    if v in ('Start', 'Stop'): return 'LIVE TRAFFIC'
    if v in ('Get', 'Resolve', 'Test', 'Connect'): return 'read'
    return 'WRITE'

def output_of(n, t):
    if n in OUTPUT_OVERRIDES: return OUTPUT_OVERRIDES[n]
    if n.startswith('Resolve-'): return 'ID, or $null if not found'
    paged = 'Invoke-Five9CloudPagedApi' in t
    if paged and "-ResultProperty" in t: return 'list of items'
    if paged: return 'page envelopes: read .items'
    if n.startswith('Get-'): return 'API response object'
    if re.search(r"return \$result|return \$r\b|return \$[a-zA-Z]+\s*\}\s*else", t): return 'API response on success; $false on failure'
    if 'return $false' in t: return 'nothing on success (prints a message); $false on failure'
    return 'nothing (prints a message): verify by re-reading'

funcs = {}
for f in sorted(glob.glob(os.path.join(ROOT, '*.ps1'))):
    t = open(f, encoding='utf-8-sig').read()
    m = re.search(r"^\s*function\s+([A-Za-z0-9-]+)", t, re.M)
    if not m or not m.group(1).startswith(('Add-','Get-','Set-','New-','Remove-','Copy-','Reset-','Start-','Stop-','Resolve-','Test-','Connect-','Invoke-')):
        continue
    n = m.group(1)
    if n in INTERNAL or n.startswith('Install-'):
        continue
    funcs[n] = {'params': params_of(t), 'effect': effect(n), 'output': output_of(n, t),
                'pipeline': 'ValueFromPipeline' in t}

groups = {a: [] for a, _ in AREAS}
for n in funcs:
    for a, pat in AREAS:
        if re.search(pat, n):
            groups[a].append(n); break

order = {'Connect':0,'Test':0,'Get':1,'Resolve':2,'New':3,'Copy':3,'Add':4,'Set':5,'Start':6,'Stop':6,'Reset':7,'Remove':8}
lines = [
    '# PSFive9CloudAPI function reference', '',
    f'Generated from the module source on {datetime.date.today().isoformat()} by `skills/tools/generate_function_reference.py`. '
    'If the user\'s installed version differs, the source wins: ask them to run `(Get-Command <Name>).Definition`.', '',
    '- **Effect**: read = no changes; WRITE = changes configuration; DESTRUCTIVE / LIVE TRAFFIC / uses credits = confirm separately.',
    '- **Parameters**: `*` = mandatory (within its parameter set). `(a\\|b)` = allowed values. Most functions accept a name *or* an ID for the target (`-CampaignName` or `-CampaignId`); pass one.',
    '- **Output**: what the function writes to the pipeline. "page envelopes" means read `.items`. Detected automatically; spot-check the source when it matters.',
    '- **Pipeline**: functions marked ⇢ accept objects piped from list functions by property name.', '',
    'Contents: ' + ', '.join(f'[{a}](#{re.sub(r"[^a-z0-9 -]", "", a.lower()).replace(" ", "-")})' for a, _ in AREAS), '',
]
for a, _ in AREAS:
    lines += [f'## {a}', '', '| Function | Effect | Parameters | Output |', '|---|---|---|---|']
    for n in sorted(groups[a], key=lambda x: (order.get(x.split('-')[0], 9), x)):
        f = funcs[n]
        p = ', '.join(f['params']) or 'none'
        lines.append(f"| `{n}`{' ⇢' if f['pipeline'] else ''} | {f['effect']} | {p} | {f['output']} |")
    lines.append('')
os.makedirs(os.path.dirname(DEST), exist_ok=True)
open(DEST, 'w', encoding='utf-8').write('\n'.join(lines))
print(f'Wrote {len(funcs)} functions to {DEST}')
