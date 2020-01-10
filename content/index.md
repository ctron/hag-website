---
layout: default
---

## Welcome to foo bar

Welcome!

{{#each full.content.games.content}}
  * [{{this.content.main.frontMatter.title}}]({{ absolute_url this.content.main.metadata.parent }})
{{/each}}
