#!/usr/bin/env python3
"""Regenerate skills/*/references/functions.md from the module's .ps1 files.

Run from the repository root:  python skills/tools/generate_function_catalogs.py
Only the references/functions.md files are rewritten. SKILL.md files are hand-edited.
"""
import re, os, glob, datetime
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SKILLS = os.path.join(ROOT, 'skills')
funcs={}
for f in sorted(glob.glob(os.path.join(ROOT,'*.ps1'))):
    name=os.path.basename(f)[:-4]
    txt=open(f,encoding='utf-8-sig').read()
    # params: [ValidateSet(...)] optional then [type]$Name
    params=[]
    seen=set()
    for m in re.finditer(r"((?:\[(?:Parameter|ValidateSet|ValidateRange)\([^\]]*\)\]\s*)*)\[(string|int|bool|switch|long|datetime|string\[\]|int\[\]|object|object\[\]|hashtable|array|PSObject)\]\s*\$([A-Za-z][A-Za-z0-9_]*)", txt):
        attrs,typ,pn=m.groups()
        if pn in seen or (pn[0].islower() and len(pn)<=3): continue
        if pn in ('page','item','credits','claims'): continue
        seen.add(pn)
        s=pn
        vs=re.search(r"ValidateSet\(([^)]*)\)",attrs)
        if vs: s+=" ("+vs.group(1).replace("'","").replace(" ","").replace(",","|")+")"
        if 'Mandatory' in attrs: s+="*"
        if typ=='switch': s+=" [switch]"
        params.append(s)
    # dynamic params
    for m in re.finditer(r"New-DynParam '([A-Za-z]+)'",txt):
        if m.group(1) not in seen: seen.add(m.group(1)); params.append(m.group(1)+" (dynamic)")
    methods=sorted(set(re.findall(r"-Method\s+'?(Post|Put|Delete|Patch|Get)",txt,re.I)))
    funcs[name]={'params':params,'methods':[x.upper() for x in methods]}

def risk(n,f):
    v=n.split('-')[0]
    if n in ('Add-Five9CloudPhoneNumber','New-Five9CloudNumberOrder'): return 'WRITE, consumes credits'
    if n=='Remove-Five9CloudPhoneNumbers': return 'DESTRUCTIVE, releases numbers'
    if v in ('Remove','Reset'): return 'DESTRUCTIVE'
    if v=='Stop': return 'DISRUPTIVE (live traffic)'
    if v=='Start': return 'DISRUPTIVE (live traffic)'
    if v in ('Get','Resolve','Test'): return 'read'
    return 'WRITE'

def cat(n):
    if n in ('Connect-Five9Cloud','Test-Five9CloudConnection','Invoke-Five9CloudApi','Invoke-Five9CloudPagedApi','Invoke-Five9CloudAuth','Invoke-Five9CloudOAuth','Set-Five9CloudToken','Get-Five9CloudAuthHeader','Get-Five9CloudJwtClaims','Set-Five9CloudQueryUri'): return 'core'
    if re.search(r'AniGroup|AniId|PhoneNumber|NumberCredits|NumberInventory|NumberOrder|DomainNumbers|CampaignNumber|UserDID',n): return 'numbers'
    if re.search(r'Campaign|Script|Prompt|Connector|Disposition',n) : return 'campaigns'
    if re.search(r'User|CannedReport|Circle|Permission|ReasonCode|Application|IdpPolicy|MFA|SkillUsers|SkillId',n): return 'users'
    return 'domain'
groups={}
for n,f in funcs.items(): groups.setdefault(cat(n),[]).append(n)
def table(ns):
    out=["| Function | Effect | Parameters (* = mandatory) |","|---|---|---|"]
    for n in sorted(ns, key=lambda x:(x.split('-')[0]!='Get', x)):
        p=", ".join(funcs[n]['params']) or "none"
        out.append(f"| `{n}` | {risk(n,funcs[n])} | {p} |")
    return "\n".join(out)
tables={g:table(ns) for g,ns in groups.items()}
HDR="Generated from the module source on {d}. Effect: read = no changes; WRITE = changes configuration; DESTRUCTIVE / DISRUPTIVE = needs the extra confirmation in SKILL.md. `*` = mandatory (within its parameter set). If the repo is cloned, the `.ps1` files win over this table.\n".format(d=datetime.date.today().isoformat())

def ref(title, groups):
    s=f"# {title}\n\n{HDR}\n"
    for g,label in groups:
        s+=f"\n## {label}\n\n{tables[g]}\n"
    return s
plan={
 'five9-cloud-users':[('users','Users, access, and user settings'),('core','Connection and plumbing')],
 'five9-cloud-campaigns':[('campaigns','Campaigns, profiles, scripts, and prompts'),('core','Connection and plumbing')],
 'five9-cloud-numbers':[('numbers','Phone numbers and ANI groups'),('core','Connection and plumbing')],
 'five9-cloud-domain':[('domain','Domain settings, tags, schedules, email, digital assistance'),('users','Users and access (for exports)'),('campaigns','Campaigns (for exports)'),('numbers','Numbers (for exports)'),('core','Connection and plumbing')],
 'five9-cloud-module-dev':[('core','Connection and plumbing'),('users','Users and access'),('campaigns','Campaigns'),('numbers','Numbers and ANI groups'),('domain','Domain')],
}
for name, groups in plan.items():
    d = os.path.join(SKILLS, name, 'references')
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'functions.md'), 'w', encoding='utf-8').write(ref('PSFive9CloudAPI functions', groups))
    print('updated', name)
