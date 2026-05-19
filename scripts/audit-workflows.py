"""
全栈交付工作流系统审查脚本（统一入口）

检查范围：
1. 全局工作流目录、README、routing.md 与标准结构一致性。
2. 已完成 skills 拆分的工作流深度检查。
3. 仍处于 template 状态的工作流占位结构检查。
4. reverse-pentest 特殊技能库入口检查。
5. 全项目 Markdown 本地链接有效性检查。

使用：
  python scripts/audit-workflows.py
"""
import os
import re
import sys
from collections import Counter

# 强制 UTF-8 输出（修复 Windows GBK 编码问题）
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if sys.stderr.encoding != 'utf-8':
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILL_REF_RE = r'([a-z0-9_-]+)/SKILL\.md'

SKILLED_WORKFLOWS = [
    'product-manager',
    'project-manager',
    'ui-ux-designer',
    'api-designer',
    'qa-engineer',
    'database-engineer',
    'backend-engineer',
    'frontend-engineer',
    'fullstack-engineer',
    'devops-engineer',
    'sre-operations',
    'security-engineer',
    'automation-qa',
    'data-analyst',
    'ai-ml-engineer',
    'technical-writer',
]

TEMPLATE_WORKFLOWS = [
]

REQUIRED_WORKFLOW_FILES = [
    'WORKFLOW.md',
    'EVOLUTION.md',
    'routing.md',
    'tool-index.md',
    'pitfalls.md',
    'field-journal/_index.md',
    'field-journal/_template.md',
]

REQUIRED_SKILL_SECTIONS = ['## 配套模板', '## 与其他 skill 的协作']

README_NAME_MAP = {
    'product-manager': '产品经理',
    'project-manager': '项目经理',
    'ui-ux-designer': 'UI/UX',
    'frontend-engineer': '前端',
    'backend-engineer': '后端',
    'fullstack-engineer': '全栈',
    'api-designer': 'API 设计',
    'database-engineer': '数据库',
    'qa-engineer': '测试工程师',
    'automation-qa': '自动化测试',
    'devops-engineer': 'DevOps',
    'sre-operations': 'SRE',
    'security-engineer': '安全工程师',
    'reverse-pentest': '逆向',
    'data-analyst': '数据分析',
    'ai-ml-engineer': 'AI',
    'technical-writer': '技术文档',
}


def rel(path):
    return os.path.relpath(path, ROOT).replace(os.sep, '/')


def read_text(path):
    with open(path, 'r', encoding='utf-8-sig') as f:
        return f.read()


def get_actual_workflows():
    workflows_dir = os.path.join(ROOT, 'workflows')
    return sorted(d for d in os.listdir(workflows_dir)
                  if os.path.isdir(os.path.join(workflows_dir, d)))


def get_routing_workflows():
    content = read_text(os.path.join(ROOT, 'routing.md'))
    return set(re.findall(r'^\s*-\s*workflow:\s*([\w-]+)', content, re.MULTILINE))


def check_global_consistency(actual):
    routing = get_routing_workflows()
    issues = []
    only_actual = set(actual) - routing
    only_routing = routing - set(actual)
    if only_actual:
        issues.append(f'  ERROR [routing.md] 目录有但路由表无: {only_actual}')
    if only_routing:
        issues.append(f'  ERROR [routing.md] 路由表有但目录无: {only_routing}')
    return issues


def check_readme_mentions(actual):
    readme = read_text(os.path.join(ROOT, 'README.md'))
    issues = []
    for wf in actual:
        cn = README_NAME_MAP.get(wf)
        if cn and cn not in readme:
            issues.append(f'  WARN [README.md] 未提及 {wf} ({cn})')
    return issues


def check_workflow_structure(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    issues = []
    for f in REQUIRED_WORKFLOW_FILES:
        if not os.path.exists(os.path.join(wf_path, f)):
            issues.append(f'  WARN [{wf}/{f}] 缺失')
    return issues


def get_actual_skills(wf_path):
    skills_dir = os.path.join(wf_path, 'skills')
    if not os.path.exists(skills_dir):
        return []
    return sorted(d for d in os.listdir(skills_dir)
                  if os.path.isdir(os.path.join(skills_dir, d))
                  and os.path.exists(os.path.join(skills_dir, d, 'SKILL.md')))


def check_skill_consistency(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    actual = set(get_actual_skills(wf_path))
    issues = []
    for fname, pattern in [
        ('WORKFLOW.md', rf'skills/{SKILL_REF_RE}'),
        ('skills/routing.md', rf'\({SKILL_REF_RE}\)'),
        ('skills/SKILL.md', rf'\({SKILL_REF_RE}\)'),
    ]:
        path = os.path.join(wf_path, fname)
        if not os.path.exists(path):
            continue
        mentioned = set(re.findall(pattern, read_text(path)))
        only_actual = actual - mentioned
        only_mentioned = mentioned - actual
        if only_actual:
            issues.append(f'  WARN [{fname}] 实际有但未提: {only_actual}')
        if only_mentioned:
            issues.append(f'  ERROR [{fname}] 提了但不存在: {only_mentioned}')
    return issues


def check_cross_references(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    actual = set(get_actual_skills(wf_path))
    issues = []
    for skill in actual:
        skill_md = os.path.join(wf_path, 'skills', skill, 'SKILL.md')
        cross_refs = re.findall(r'\.\./([a-z0-9_-]+)/SKILL\.md', read_text(skill_md))
        invalid = set(cross_refs) - actual
        if invalid:
            issues.append(f'  ERROR [{skill}/SKILL.md] 引用不存在的 skill: {invalid}')
    return issues


def check_template_references(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    issues = []
    for skill in get_actual_skills(wf_path):
        skill_dir = os.path.join(wf_path, 'skills', skill)
        templates_dir = os.path.join(skill_dir, 'templates')
        content = read_text(os.path.join(skill_dir, 'SKILL.md'))
        template_refs = set(re.findall(r'`templates/([\w\-./]+\.md)`', content))
        actual_templates = set()
        if os.path.exists(templates_dir):
            for root, _, files in os.walk(templates_dir):
                for f in files:
                    if f.endswith('.md') and f != 'README.md':
                        actual_templates.add(os.path.relpath(os.path.join(root, f), templates_dir).replace(os.sep, '/'))
        missing = {r for r in template_refs if not os.path.exists(os.path.join(templates_dir, r))}
        unused = actual_templates - template_refs
        if missing:
            issues.append(f'  ERROR [{skill}/SKILL.md] 引用不存在的模板: {missing}')
        if unused:
            issues.append(f'  WARN [{skill}/templates] 存在但未引用: {unused}')
    return issues


def check_duplicate_template_refs(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    issues = []
    for skill in get_actual_skills(wf_path):
        skill_md = os.path.join(wf_path, 'skills', skill, 'SKILL.md')
        content = read_text(skill_md)
        m = re.search(r'## 配套模板\s*\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
        if not m:
            continue
        refs = re.findall(r'`templates/([\w\-./]+\.md)`', m.group(1))
        dups = {n: c for n, c in Counter(refs).items() if c > 1}
        if dups:
            issues.append(f'  WARN [{skill}/SKILL.md 配套模板] 重复引用: {dups}')
    return issues


def check_skills_meta_files(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    issues = []
    for fname in ['skills/SKILL.md', 'skills/routing.md', 'skills/CONTRIBUTING.md']:
        if not os.path.exists(os.path.join(wf_path, fname)):
            issues.append(f'  ERROR [{fname}] 缺失')
    return issues


def check_skill_md_quality(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    issues = []
    for skill in get_actual_skills(wf_path):
        skill_md = os.path.join(wf_path, 'skills', skill, 'SKILL.md')
        content = read_text(skill_md)
        if not content.startswith('---'):
            issues.append(f'  WARN [{skill}/SKILL.md] 缺少 YAML frontmatter')
        else:
            m = re.match(r'---\s*\n(.*?)\n---', content, re.DOTALL)
            if m:
                fm = m.group(1)
                if 'name:' not in fm:
                    issues.append(f'  WARN [{skill}/SKILL.md] frontmatter 缺少 name 字段')
                if 'description:' not in fm:
                    issues.append(f'  WARN [{skill}/SKILL.md] frontmatter 缺少 description 字段')
        for sec in REQUIRED_SKILL_SECTIONS:
            if sec not in content:
                issues.append(f'  WARN [{skill}/SKILL.md] 缺少章节 "{sec}"')
    return issues


def check_skills_index_routing_consistency(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    issues = []
    skill_md = os.path.join(wf_path, 'skills/SKILL.md')
    routing_md = os.path.join(wf_path, 'skills/routing.md')
    if not (os.path.exists(skill_md) and os.path.exists(routing_md)):
        return issues
    skill_set = set(re.findall(rf'\({SKILL_REF_RE}\)', read_text(skill_md)))
    routing_set = set(re.findall(rf'\({SKILL_REF_RE}\)', read_text(routing_md)))
    only_index = skill_set - routing_set
    only_routing = routing_set - skill_set
    if only_index:
        issues.append(f'  WARN [skills/SKILL.md vs routing.md] 总控有但路由无: {only_index}')
    if only_routing:
        issues.append(f'  WARN [skills/SKILL.md vs routing.md] 路由有但总控无: {only_routing}')
    return issues


def check_template_workflow(wf):
    wf_path = os.path.join(ROOT, 'workflows', wf)
    issues = []
    routing_md = os.path.join(wf_path, 'routing.md')
    routing = read_text(routing_md) if os.path.exists(routing_md) else ''
    if 'status: template' not in routing:
        issues.append(f'  WARN [{wf}/routing.md] 模板工作流未标记 status: template')
    if not os.path.exists(os.path.join(wf_path, 'skills', '_template', 'SKILL.md')):
        issues.append(f'  ERROR [{wf}/skills/_template/SKILL.md] 模板工作流缺少占位 skill')
    if not os.path.exists(os.path.join(wf_path, 'skills', 'routing.md')):
        issues.append(f'  ERROR [{wf}/skills/routing.md] 模板工作流缺少 skill 路由')
    return issues


def check_reverse_pentest():
    wf_path = os.path.join(ROOT, 'workflows', 'reverse-pentest')
    issues = []
    for fname in [
        'reverse-skill-private/skills/SKILL.md',
        'reverse-skill-private/skills/routing.md',
        'reverse-skill-private/skills/tool-index.md',
        'reverse-skill-private/skills/field-journal/_index.md',
    ]:
        if not os.path.exists(os.path.join(wf_path, fname)):
            issues.append(f'  ERROR [reverse-pentest/{fname}] 缺失')
    for fname in ['routing.md', 'tool-index.md', 'pitfalls.md']:
        path = os.path.join(wf_path, fname)
        if os.path.exists(path):
            content = read_text(path)
            if r'`\text' in content or r'`\yaml' in content or '"@' in content or '鈥' in content:
                issues.append(f'  ERROR [reverse-pentest/{fname}] 疑似包含损坏的 PowerShell 模板残留')
    return issues


def iter_markdown_files():
    for root, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d != '.git']
        for f in files:
            if f.endswith('.md'):
                yield os.path.join(root, f)


def mask_code_spans(content):
    def blank(match):
        return ''.join('\n' if ch == '\n' else ' ' for ch in match.group(0))

    content = re.sub(r'```.*?```', blank, content, flags=re.DOTALL)
    content = re.sub(r'`[^`\n]*`', blank, content)
    return content


def is_external_or_anchor(target):
    lowered = target.lower()
    return (
        not target
        or target.startswith('#')
        or target.startswith('/')
        or target.isdigit()
        or target[0] in {'"', "'"}
        or '://' in target
        or lowered.startswith('mailto:')
        or lowered.startswith('data:')
        or lowered.startswith('javascript:')
    )


def check_markdown_links():
    issues = []
    link_re = re.compile(r'\[[^\]]+\]\(([^)]+)\)')
    for path in iter_markdown_files():
        content = read_text(path)
        scan_content = mask_code_spans(content)
        for m in link_re.finditer(scan_content):
            raw_target = m.group(1).strip()
            target = raw_target.split('#', 1)[0]
            if is_external_or_anchor(target):
                continue
            target_path = os.path.normpath(os.path.join(os.path.dirname(path), target))
            if not os.path.exists(target_path):
                line = content[:m.start()].count('\n') + 1
                issues.append(f'  ERROR [{rel(path)}:{line}] 本地链接不存在: {raw_target}')
    return issues


def print_section(title):
    print(f'\n{"="*60}')
    print(title)
    print(f'{"="*60}')


def print_issues(issues):
    errors = 0
    warns = 0
    if not issues:
        print('  [PASS] 无问题')
        return errors, warns
    for issue in issues:
        print(issue)
        if 'ERROR' in issue:
            errors += 1
        elif 'WARN' in issue:
            warns += 1
    return errors, warns


def main():
    total_errors = 0
    total_warns = 0
    actual = get_actual_workflows()

    print_section(f'A. 全局完整性审查（{len(actual)} 个工作流）')
    global_issues = []
    global_issues.extend(check_global_consistency(actual))
    global_issues.extend(check_readme_mentions(actual))
    for wf in actual:
        global_issues.extend(check_workflow_structure(wf))
    errors, warns = print_issues(global_issues)
    total_errors += errors
    total_warns += warns

    for wf in SKILLED_WORKFLOWS:
        print_section(f'B. Skills 深度审查: {wf}')
        all_issues = []
        all_issues.extend(check_skills_meta_files(wf))
        all_issues.extend(check_skill_consistency(wf))
        all_issues.extend(check_cross_references(wf))
        all_issues.extend(check_template_references(wf))
        all_issues.extend(check_duplicate_template_refs(wf))
        all_issues.extend(check_skill_md_quality(wf))
        all_issues.extend(check_skills_index_routing_consistency(wf))
        errors, warns = print_issues(all_issues)
        total_errors += errors
        total_warns += warns

    print_section('C. Template 工作流占位结构审查')
    template_issues = []
    for wf in TEMPLATE_WORKFLOWS:
        template_issues.extend(check_template_workflow(wf))
    errors, warns = print_issues(template_issues)
    total_errors += errors
    total_warns += warns

    print_section('D. reverse-pentest 特殊工作流审查')
    errors, warns = print_issues(check_reverse_pentest())
    total_errors += errors
    total_warns += warns

    print_section('E. Markdown 本地链接审查')
    errors, warns = print_issues(check_markdown_links())
    total_errors += errors
    total_warns += warns

    print_section(f'总计: {total_errors} 个错误, {total_warns} 个警告')
    return 0 if total_errors == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
