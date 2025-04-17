# Importmap-CR ‑ A framework‑agnostic import‑map shard for Crystal

> **Load JavaScript modules without bundlers**
> Define pins in Crystal, merge them per‑namespace, and render a `<script type="importmap">` tag at runtime.

[![CI](https://github.com/treagod/import_map/actions/workflows/ci.yml/badge.svg)](https://github.com/treagod/import_map/actions/workflows/ci.yml)

---

## ✨ Features

* **Crystal DSL** – declare pins and namespaces in pure Crystal code.
* **Namespaced import maps** – serve different JS sets for *public*, *admin*, etc.
* **Module‑preload links** – automatic `<link rel="modulepreload">` for every pin (opt‑out supported).
* **Pluggable resolver** – hook in your asset pipeline to rewrite `/js/app.js` → `/assets/app‑abc123.js`.
* **Zero runtime overhead** – import‑map JSON is cached on boot.

---

## 📦 Installation

Add the shard to your `shard.yml` and run `shards install`.

```yaml
dependencies:
  importmap:
    github: treagod/importmap
    version: "~> 0.1.0"
```

## 🚀 Quick start

1. Configure pins

```crystal
require "importmap"

Importmap.draw do
  # Base pins (preload = true by default)
  pin "stimulus", "/js/stimulus.js"

  namespace "admin" do
    pin "admin-ui", "/js/admin.js", preload: false # opt‑out
  end
end
```

2. (Optional) integrate a resolver

```crystal
Importmap.resolver = ->(path : String) { "/assets#{path}?v=abc" }
```

3. Render the tags

```crystal
Importmap.tag

# admin namespace with an custom entrypoint
Importmap.tag("admin", entrypoint: "admin-ui")
```

Result:

```html
<link rel="modulepreload" href="/js/stimulus.js">
<script type="importmap">{"imports":{"stimulus":"/js/stimulus.js"}}</script>

<!-- admin namespace -->
<link rel="modulepreload" href="/js/stimulus.js">
<script type="importmap" data-namespace="admin">{"imports":{"stimulus":"/js/stimulus.js","admin-ui":"/js/admin.js"}}</script>
<script type="module">import "admin-ui"</script>
```


## 📚 Roadmap

- CLI tool for pinning/unpinning CDN packages
- Static build command (importmap build)
- Vulnerability & outdated‑package audit
- Add scopes

## 💡 Contributing

1. Fork, create a feature branch.
2. `shards install && crystal spec` (all tests should pass).
3. Open a PR!
