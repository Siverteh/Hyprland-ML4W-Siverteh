"""Evidence-led subject discovery. No project registry, fixed subjects or folder taxonomy."""

import collections, hashlib, math, re, unicodedata

STOP = set(
    "a an the and or but of to in on for with from by at as is are was were be been being this that these those it its my your our their we you they i me he she them have has had do does did can could should would will may into about after before through more most some any all each only other no not new now then than also just how what when where which who why use used using make made first last one two current latest source recorded reviewed confidence entity name parent project worlds topics tags category aliases status evidence note notes knowledge verified reported unverified sourcepage test tests passed check checks result results update updated updating completed complete ready fixed fix added add deployed deploy deployment implement implementation source code files file path paths branch worktree commit git user assistant workflow context saved private local scope preserve existing unchanged previous version changes changed change correct documented requested default actual explicit native shell runtime process processes window windows gui ui cli service services script scripts command commands configuration config settings clean done shows show setup verified validation milestone historical observations observation captured capture memory suggestions suggested subject subjects".split()
)


def key(value):
    return unicodedata.normalize("NFKC", str(value)).casefold().strip()


def slug(value):
    value = re.sub(
        r"[^a-z0-9]+",
        "-",
        unicodedata.normalize("NFKD", str(value))
        .encode("ascii", "ignore")
        .decode()
        .lower(),
    ).strip("-")[:80]
    return value or "subject-" + hashlib.sha256(key(value).encode()).hexdigest()[:12]


def items(value):
    return [
        v.strip().strip("\"'") for v in str(value).strip("[]").split(",") if v.strip()
    ]


def clean(text):
    text = re.sub(r"(?ms)^```[^\n]*\n.*?^```[^\n]*$", " ", text)
    text = re.sub(r"`[^`]+`", " ", text)
    text = re.sub(
        r"(?mi)^(Source|Recorded|Reviewed|Confidence|Entity|Name|Parent|Project|Worlds|Topics|Tags|Category|Aliases|Status):[^\n]*",
        " ",
        text,
    )
    text = re.sub(
        r"https?://\S+|(?:~|/)[\w./%-]+|\b[0-9a-f]{12,}\b", " ", text, flags=re.I
    )
    return text


def tokens(text):
    return [
        w.casefold()
        for w in re.findall(r"[^\W\d_]{3,}", text)
        if w.casefold() not in STOP
    ]


def features(note):
    body = clean(note["text"])
    title = note["label"]
    counts = collections.Counter(tokens(title) * 3 + tokens(body[:5000]))
    return counts, title + "\n" + body[:1100] + "\n" + body[-350:]


def normalized(vector):
    norm = math.sqrt(sum(v * v for v in vector.values()))
    return {k: v / norm for k, v in vector.items()} if norm else {}


def lexical(notes):
    counts = {n["id"]: features(n)[0] for n in notes}
    df = collections.Counter(w for c in counts.values() for w in c)
    return {
        ident: normalized(
            {
                w: (1 + math.log(tf)) * math.log(1 + len(notes) / (1 + df[w]))
                for w, tf in count.items()
            }
        )
        for ident, count in counts.items()
    }


def cosine(a, b):
    return sum(value * b.get(term, 0) for term, value in a.items())


def dense_cos(a, b):
    return sum(x * y for x, y in zip(a, b)) if a and b else 0


def centroid(ids, vectors):
    result = collections.Counter()
    for ident in ids:
        result.update(vectors.get(ident, {}))
    return normalized(result)


def dense_centroid(ids, vectors):
    values = [vectors[i] for i in ids if i in vectors]
    if not values:
        return []
    result = [sum(v[j] for v in values) / len(values) for j in range(len(values[0]))]
    norm = math.sqrt(sum(v * v for v in result))
    return [v / norm for v in result] if norm else []


def similarity(a, b, lex, dense):
    sparse = cosine(lex.get(a, {}), lex.get(b, {}))
    semantic = dense_cos(dense.get(a, []), dense.get(b, []))
    return 0.65 * semantic + 0.35 * sparse if a in dense and b in dense else sparse


def label_cluster(ids, notes, lex):
    scores = collections.Counter()
    phrases = collections.defaultdict(set)
    spellings = {}
    for ident in ids:
        n = notes[ident]
        scores.update(lex.get(ident, {}))
        words = re.findall(r"[^\W\d_]{3,}", n["label"])
        for word in words:
            spellings.setdefault(key(word), word)
        for size in (2, 3):
            for i in range(len(words) - size + 1):
                phrase = " ".join(words[i : i + size])
                if all(key(w) not in STOP for w in words[i : i + size]):
                    phrases[phrase].add(ident)
    best = max(scores, key=scores.get, default="Unsorted knowledge")
    options = [
        (
            sum(scores[key(w)] for w in phrase.split()) / len(phrase.split()) * 1.2,
            phrase,
        )
        for phrase, members in phrases.items()
        if len(members) >= 2 and best in tokens(phrase)
    ]
    if options:
        return max(options)[1]
    word = spellings.get(best, best)
    return word if any(c.isupper() for c in word[1:]) else word.capitalize()


def communities(ids, lex, dense, minimum=3):
    # Average-link merging plus a weakest-pair guard prevents one bridging note joining unrelated groups.
    groups = [{i} for i in sorted(ids)]
    pairs = {}

    def sim(a, b):
        k = tuple(sorted((a, b)))
        if k not in pairs:
            pairs[k] = similarity(a, b, lex, dense)
        return pairs[k]

    threshold = 0.53 if dense else 0.32
    while True:
        best = None
        for i, a in enumerate(groups):
            for j in range(i + 1, len(groups)):
                values = [sim(x, y) for x in a for y in groups[j]]
                score = sum(values) / len(values)
                if (
                    score >= threshold
                    and min(values) >= threshold * 0.65
                    and (best is None or score > best[0])
                ):
                    best = (score, i, j)
        if best is None:
            break
        _, i, j = best
        groups[i] |= groups.pop(j)
    return [sorted(g) for g in groups if len(g) >= minimum]


def organize(notes, dense=None, prior=None, overrides=None):
    dense = dense or {}
    prior = prior or {}
    overrides = overrides or {}
    by = {n["id"]: n for n in notes}
    lex = lexical(notes)
    subjects = {}
    aliases = {}
    topic_specs = []
    assigned = collections.defaultdict(dict)

    def add(label, ident=None, alias=(), origin="annotated", category=None, path=None):
        existing = aliases.get(key(label))
        if existing:
            return subjects[existing]
        ident = ident or next(
            (
                v["id"]
                for v in prior.get("discovered", [])
                if key(v["label"]) == key(label)
            ),
            slug(label),
        )
        if ident in subjects and key(subjects[ident]["label"]) != key(label):
            ident += "-" + hashlib.sha256(label.encode()).hexdigest()[:6]
        s = subjects.setdefault(
            ident,
            dict(
                id=ident,
                label=label,
                aliases=[],
                origin=origin,
                category=category,
                path=path,
                members={},
                topics=[],
                parent=None,
            ),
        )
        for name in [label, ident, *alias]:
            if name and key(name) not in aliases:
                aliases[key(name)] = ident
                s["aliases"].append(name)
        return s

    def resolve(value):
        return aliases.get(key(value)) or aliases.get(key(slug(value)))

    def attach(note, subject, reason, score=1):
        if note in overrides and reason != "manual grouping":
            return
        if subject in subjects:
            assigned[note][subject] = dict(reason=reason, score=round(score, 3))
            subjects[subject]["members"][note] = assigned[note][subject]

    # Curated declarations and explicit annotations are authority; raw imports cannot declare entities.
    for n in notes:
        m = n["meta"]
        kind = m.get("entity", "")
        if (
            n["path"].startswith("wiki/")
            and (
                kind in ("world", "project", "person", "interest", "idea", "device")
                or not kind
                and len(n["label"].split()) <= 5
            )
            and not m.get("parent")
        ):
            s = add(
                m.get("name") or n["label"],
                m.get("project") or slug(n["path"].split("/")[-1].removesuffix(".md")),
                items(m.get("aliases", ""))
                + [n["path"].split("/")[-1].removesuffix(".md")],
                category=m.get("category"),
                path=n["path"],
            )
            attach(n["id"], s["id"], "curated")
    for n in notes:
        if n["path"].startswith("raw/"):
            continue
        m = n["meta"]
        for label in items(m.get("worlds", "")):
            s = add(label)
            attach(n["id"], s["id"], "annotation")
        if m.get("project") and m.get("entity") not in ("topic", "device"):
            ident = resolve(m["project"])
            s = (
                subjects[ident]
                if ident
                else add(m["project"].replace("-", " ").title(), slug(m["project"]))
            )
            attach(n["id"], s["id"], "annotation")
    # A user's grouping correction overrides historical annotations and becomes a strong anchor.
    for n in notes:
        if n["id"] not in overrides:
            continue
        for subject in subjects.values():
            subject["members"].pop(n["id"], None)
        assigned[n["id"]] = {}
        for label in overrides[n["id"]]:
            s = add(label, origin="manual")
            attach(n["id"], s["id"], "manual grouping")
    # Explicit curated evidence links give an anchor to legacy evidence without keyword shortcuts.
    paths = {n["path"]: n["id"] for n in notes}
    for s in list(subjects.values()):
        if not s["path"]:
            continue
        page = by[paths[s["path"]]]
        for target in page.get("references", []):
            if target not in overrides:
                attach(target, s["id"], "curated reference")
    for n in notes:
        m = n["meta"]
        if n["path"].startswith("wiki/") and m.get("entity") in ("topic", "device"):
            parent = resolve(m.get("parent") or m.get("project", ""))
            if parent:
                label = m.get("name") or n["label"]
                topic_specs.append(
                    dict(
                        id=parent
                        + ":entity-"
                        + slug(n["path"].split("/")[-1].removesuffix(".md")),
                        label=label,
                        parent=parent,
                        category=m.get("category"),
                        members={n["id"]},
                        origin="annotated",
                    )
                )
                attach(n["id"], parent, "curated topic")
    # Exact named mentions in titles, longest first; ambiguous namespace prefixes are not personal matches.
    names = sorted(
        [
            (name, s["id"])
            for s in subjects.values()
            for name in s["aliases"]
            if len(name) >= 4
        ],
        key=lambda v: -len(v[0]),
    )
    for n in notes:
        if assigned[n["id"]]:
            continue
        title = key(n["label"])
        found = []
        for name, ident in names:
            ambiguous = any(
                key(other["label"]).startswith(key(name) + " ") and other["id"] != ident
                for other in subjects.values()
            )
            if ambiguous and title != key(name):
                continue
            if re.search(
                r"(?<!\w)" + re.escape(key(name)) + r"(?!\w)", title
            ) and not any(key(name) in key(longer) for longer, _ in found):
                found.append((name, ident))
        for _, ident in found[:2]:
            attach(n["id"], ident, "named title")
    for n in notes:
        if assigned[n["id"]]:
            continue
        intro = key(clean(n["text"])[:900])
        for name, ident in names:
            if any(
                key(other["label"]).startswith(key(name) + " ") and other["id"] != ident
                for other in subjects.values()
            ):
                continue
            match = re.search(r"(?<!\w)" + re.escape(key(name)) + r"(?!\w)", intro)
            if not match:
                continue
            before = intro[max(0, match.start() - 45) : match.start()]
            if re.search(
                r"\b(unrelated|unchanged|preserve|without|no|not|example|fixture)\b",
                before,
            ):
                continue
            attach(n["id"], ident, "named evidence")
            if len(assigned[n["id"]]) >= 2:
                break
    # A repeated specific new name is an identity signal, not just another note in a familiar domain.
    # Detect it before prototype assignment so a new electronics project is not swallowed by an old one.
    novel = collections.defaultdict(set)
    for n in notes:
        if assigned[n["id"]]:
            continue
        for name in re.findall(
            r"\b(?:[A-Z][a-z]+[A-Z][A-Za-z]*|[A-Z]{4,})\b", n["label"]
        ):
            if not resolve(name):
                novel[name].add(n["id"])
    for label, ids in sorted(novel.items(), key=lambda p: (-len(p[1]), p[0])):
        ids = [i for i in sorted(ids) if not assigned[i]]
        evidence = {
            hashlib.sha256(
                (by[i]["label"] + "\n" + clean(by[i]["text"])).casefold().encode()
            ).hexdigest()
            for i in ids
        }
        if len(evidence) < 3:
            continue
        pairs = [similarity(a, b, lex, dense) for a in ids for b in ids if a < b]
        if sum(pairs) / max(1, len(pairs)) < (0.35 if dense else 0.18):
            continue
        s = add(label, "discovered-" + slug(label), origin="discovered")
        for ident in ids:
            attach(ident, s["id"], "repeated named subject", 0.75)
    # Profiles learn only from grounded anchors, then generalize by local semantics + discriminative terms.
    profiles = {
        i: (centroid(s["members"], lex), dense_centroid(s["members"], dense))
        for i, s in subjects.items()
        if s["members"]
    }
    for n in notes:
        if assigned[n["id"]]:
            continue
        scores = []
        for ident, (sparse, semantic) in profiles.items():
            score = cosine(lex[n["id"]], sparse)
            if n["id"] in dense and semantic:
                score = 0.65 * dense_cos(dense[n["id"]], semantic) + 0.35 * score
            scores.append((score, ident))
        scores.sort(reverse=True)
        if scores and scores[0][0] >= (0.47 if dense else 0.24):
            if (
                len(scores) > 1
                and scores[1][0] >= scores[0][0] * 0.91
                and scores[0][0] - scores[1][0] < 0.055
            ):
                n["suggestions"] = [
                    dict(subject=i, score=round(v, 3)) for v, i in scores[:2]
                ]
                continue
            attach(n["id"], scores[0][1], "learned similarity", scores[0][0])
    # Residual coherent evidence becomes a subject without needing a registry or descriptor page.
    residual = [
        n["id"]
        for n in notes
        if not assigned[n["id"]] and not n["path"].startswith("raw/")
    ]
    discovered = [
        dict(id=s["id"], label=s["label"], members=sorted(s["members"]))
        for s in subjects.values()
        if s["origin"] == "discovered"
    ]
    named = collections.defaultdict(set)
    for ident in residual:
        for word in re.findall(r"\b[A-Z][A-Za-z]{3,}\b", by[ident]["label"]):
            if key(word) not in STOP:
                named[word].add(ident)
    named_groups = []
    for label, members in sorted(
        named.items(), key=lambda pair: (-len(pair[1]), pair[0])
    ):
        if len(members) < 3:
            continue
        pairs = [
            similarity(a, b, lex, dense) for a in members for b in members if a < b
        ]
        if sum(pairs) / max(1, len(pairs)) < (0.35 if dense else 0.18):
            continue
        group = [i for i in sorted(members) if not assigned[i]]
        if (
            len(group) < 3
            or len(
                {
                    hashlib.sha256(
                        (by[i]["label"] + "\n" + clean(by[i]["text"]))
                        .casefold()
                        .encode()
                    ).hexdigest()
                    for i in group
                }
            )
            < 3
        ):
            continue
        named_groups.append((label, group))
    for label, group in named_groups:
        label = (
            label_cluster(group, by, lex)
            if not (label.isupper() or any(c.isupper() for c in label[1:]))
            else label
        )
        label = label[0].upper() + label[1:]
        related = []
        for ident, (sparse, semantic) in profiles.items():
            score = cosine(centroid(group, lex), sparse)
            if dense and semantic:
                score = (
                    0.65 * dense_cos(dense_centroid(group, dense), semantic)
                    + 0.35 * score
                )
            related.append((score, ident))
        related.sort(reverse=True)
        if related and related[0][0] >= (0.4 if dense else 0.2):
            parent = related[0][1]
            for ident in group:
                attach(ident, parent, "suggested named topic", related[0][0])
            topic_specs.append(
                dict(
                    id=parent + ":learned-" + slug(label),
                    label=label,
                    parent=parent,
                    category=None,
                    members=set(group),
                    origin="suggested",
                )
            )
            continue
        s = add(label, "discovered-" + slug(label), origin="discovered")
        for ident in group:
            attach(ident, s["id"], "repeated named subject", 0.7)
        discovered.append(dict(id=s["id"], label=label, members=group))
    residual = [i for i in residual if not assigned[i]]
    for group in communities(residual, lex, dense):
        evidence = {
            hashlib.sha256(
                (n["label"] + "\n" + clean(n["text"])).casefold().encode()
            ).hexdigest()
            for n in (by[i] for i in group)
        }
        if len(evidence) < 3:
            continue
        label = label_cluster(group, by, lex)
        label = label[0].upper() + label[1:]
        related = []
        for ident, (sparse, semantic) in profiles.items():
            sparse_score = cosine(centroid(group, lex), sparse)
            score = (
                0.65 * dense_cos(dense_centroid(group, dense), semantic)
                + 0.35 * sparse_score
                if dense and semantic
                else sparse_score
            )
            related.append((score, ident))
        related.sort(reverse=True)
        if len(evidence) < 5 and related and related[0][0] >= (0.4 if dense else 0.2):
            parent = related[0][1]
            for note in group:
                attach(note, parent, "suggested community", related[0][0])
            topic_specs.append(
                dict(
                    id=parent + ":learned-" + slug(label),
                    label=label,
                    parent=parent,
                    category=None,
                    members=set(group),
                    origin="suggested",
                )
            )
            continue
        if len(evidence) < 5:
            continue
        old = None
        overlap = 0
        for candidate in prior.get("discovered", []):
            score = len(set(group) & set(candidate["members"])) / max(
                1, min(len(group), len(candidate["members"]))
            )
            if score > 0.55 and score > overlap:
                old = candidate
                overlap = score
        ident = old["id"] if old else "discovered-" + slug(label)
        label = old["label"] if old else label
        s = add(label, ident, origin="discovered")
        for note in group:
            attach(note, s["id"], "discovered community", 0.65)
        discovered.append(dict(id=s["id"], label=s["label"], members=group))
    # Topic annotations are exact membership, not all notes mentioning a generic word.
    for s in list(subjects.values()):
        tags = collections.defaultdict(set)
        for ident in s["members"]:
            for label in items(
                by[ident]["meta"].get("topics", by[ident]["meta"].get("tags", ""))
            ):
                tags[label].add(ident)
        for label, members in tags.items():
            topic_specs.append(
                dict(
                    id=s["id"] + ":tag-" + slug(label),
                    label=label,
                    parent=s["id"],
                    members=members,
                    origin="annotated",
                    category=None,
                )
            )
        covered = (
            set().union(*(t["members"] for t in topic_specs if t["parent"] == s["id"]))
            if any(t["parent"] == s["id"] for t in topic_specs)
            else set()
        )
        for group in communities(
            [i for i in s["members"] if i not in covered], lex, dense
        ):
            label = label_cluster(group, by, lex)
            if key(label) == key(s["label"]):
                continue
            topic_specs.append(
                dict(
                    id=s["id"] + ":learned-" + slug(label),
                    label=label,
                    parent=s["id"],
                    members=set(group),
                    origin="suggested",
                    category=None,
                )
            )
    # Combine duplicate representations of the same topic; curated/annotated names win.
    unique = {}
    for topic in topic_specs:
        identity = (topic["parent"], key(topic["label"]))
        if identity not in unique:
            unique[identity] = topic
        else:
            old = unique[identity]
            members = old["members"] | topic["members"]
            if topic["origin"] == "annotated" and old["origin"] != "annotated":
                unique[identity] = topic
            unique[identity]["members"] = members
    topic_specs = list(unique.values())
    # Grounded topic pages can associate old notes through a profile, with a visible suggested origin.
    for topic in topic_specs:
        for n in notes:
            if topic["parent"] not in assigned[n["id"]] or n["id"] in topic["members"]:
                continue
            if re.search(
                r"(?<!\w)" + re.escape(key(topic["label"])) + r"(?!\w)", key(n["label"])
            ):
                topic["members"].add(n["id"])
        subjects[topic["parent"]]["topics"].append(topic)
    # Major promotion is support + diversity + relative focus, never one mention or one copied template.
    promotions = []
    for topic in topic_specs:
        group = [by[i] for i in topic["members"] if by[i].get("recorded")]
        days = {n["date"] for n in group}
        parent = subjects[topic["parent"]]
        support = {
            hashlib.sha256(clean(n["text"]).casefold().encode()).hexdigest()
            for n in group
        }
        total = sum(
            by[i]["activity"] for i in parent["members"] if by[i].get("recorded")
        )
        weight = sum(n["activity"] for n in group)
        if (
            (
                len(support) >= 5
                and len(days) >= 2
                and weight / max(total, 0.001) >= 0.35
            )
            or (
                "subject-" + slug(topic["label"]) in prior.get("promoted", [])
                and len(support) >= 3
            )
        ) and not resolve(topic["label"]):
            major = add(
                topic["label"], "subject-" + slug(topic["label"]), origin="promoted"
            )
            major["parent"] = parent["id"]
            for n in group:
                attach(n["id"], major["id"], "promoted topic")
            promotions.append(major["id"])
    unresolved = [n["id"] for n in notes if not assigned[n["id"]]]
    if unresolved:
        s = add("Needs grouping", "review", origin="review")
        for ident in unresolved:
            attach(ident, s["id"], "unresolved", 0)
    for n in notes:
        n["memberships"] = [
            dict(subject=i, **reason) for i, reason in assigned[n["id"]].items()
        ]
    return [s for s in subjects.values() if s["members"]], dict(
        discovered=discovered,
        promoted=promotions,
        review=len(unresolved),
        method="semantic + lexical" if dense else "lexical fallback",
    )
