---
title: "Hugo: Crafting Your Digital Identity"
date: 2019-10-27T10:42:00+02:00
draft: false
featureimage: /img/posts/gohugo/featured.svg
showTableOfContents: false
summary: Post about how I build this blog ... like any developer must-do.
tags:
- hugo
- staticsite
- github
- opensource
categories:
- Technical posts
- Open Source
---

I brought a domain name `romainlespinasse.dev`, so naturally I search to build a website, a small one.

* to give access to some social links about me,
* to make available all my posts across blog platforms (Company blog site, Medium, Dev.to).

I choose

* to build a static site with [Hugo](https://gohugo.io/)
* support by Continuous Delivery using [Github Actions](https://github.com/features/actions)
* to deploy it on [GitHub User site](https://pages.github.com/).

## Step 1 | Build the site

After [installing Hugo](https://gohugo.io/getting-started/installing/), I bootstrap a site for `romainlespinasse.dev` and initialize a git repository :

```shell
hugo new site rlespinasse.github.io
cd rlespinasse.github.io
git init
```

To have a good looking site, I choose one of the theme from [https://themes.gohugo.io/](https://themes.gohugo.io/).
The chosen theme is a simple one, adapt for a personal site : [Hermit](https://github.com/Track3/hermit.git).

As documented, I add it as `git submodule` :

```shell
git submodule add https://github.com/Track3/hermit.git themes/hermit
```

Now, I need to configure the site with my own settings.
The setup part is managed by the `config.toml` file :

```toml
# access url (use to setup links inside the site)
baseURL = "https://www.romainlespinasse.dev"
# Title (for the '<title>' html tag)
title = "Romain Lespinasse"
# site language
languageCode = "en-us"
defaultContentLanguage = "en"
# theme
theme = "hermit"
# folder to serve static files
# '/static/image.png' will be available at 'https://www.romainlespinasse.dev/image.png'
staticDir = ["static"]

# additional configuration from hermit theme (see themes/hermit/exampleSite/config.toml)
```

I add the `hermit` additional configuration and made some changes :

* `copyright` to set the chosen license for this site: [MIT License](https://opensource.org/licenses/MIT),
* `googleAnalytics` to have some analytics about my site,
* Some social links to Twitter, LinkedIn or GitHub accounts.

After configuration, I start to write the first post of my site.
Hugo can serve locally the site with live reloading capabilities :

```shell
$ hugo serve -D
...
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

Hugo can also create post template `hugo new posts/gohugo.md`

A sample from this current blog post :

```md
---
title: "Hugo | Generate your own site"
date: 2019-10-27T10:42:00+02:00
draft: false
tags:
  - feedback
  - hugo
  - staticsite
  - github
---

I brought a domain name `romainlespinasse.dev`, so naturally I search to build a website, a small one.
```

To build the static site, I just run `hugo` and setup generated folders as ignored by git :

Content of `.gitignore`

```text
resources/_gen
public/
```

## Step 2 | Add Continuous Delivery

Since I'm using GitHub for hosting my git repository, I setup

* a Github action to build and deploy the site on the default branch: `sources`,
* a GitHub action to build the site on every branches and pull-requests in order to validate the content of the static site.

[peaceiris](https://github.com/peaceiris) have created some useful GitHub actions to my usecase :

* Build a `Hugo` site with [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo),
* Push content to a specific branch [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages) used to push GitHub pages.

In `.github/workflows/build.yaml` file, the following action will, on any branch except `sources` branch :

* checkout the git repository with its submodules,
* build the `hugo` site.

```yaml
name: build

on:
  push:
    branches-ignore:
    - sources

jobs:
  build:
    runs-on: ubuntu-18.04
    steps:
    - uses: actions/checkout@master
      with:
        submodules: true

    - name: Setup Hugo
      uses: peaceiris/actions-hugo@v2.2.2
      with:
        hugo-version: '0.58.3'
        extended: true

    - name: Build
      run: |
        hugo --gc --minify
```

In `.github/workflows/deploy.yaml` file, the following action will, on `sources` branch :

* checkout the git repository with its submodules,
* build the `hugo` site,
* deploy the content of `public` folder to `master` branch in order to serve as GitHub pages.

```yaml
name: deploy

on:
  push:
    branches:
    - sources

jobs:
  build-deploy:
    runs-on: ubuntu-18.04
    steps:
    - uses: actions/checkout@master
      with:
        submodules: true

    - name: Setup Hugo
      uses: peaceiris/actions-hugo@v2.2.2
      with:
        hugo-version: '0.58.3'
        extended: true

    - name: Build
      run: |
        hugo --gc --minify

    - name: Deploy
      uses: peaceiris/actions-gh-pages@v2.5.0
      env:
        ACTIONS_DEPLOY_KEY: ${{ secrets.ACTIONS_DEPLOY_KEY }}
        PUBLISH_BRANCH: master
        PUBLISH_DIR: ./public
```

To setup `secrets.ACTIONS_DEPLOY_KEY`, I follow the [`peaceiris/actions-gh-pages` guideline](https://github.com/peaceiris/actions-gh-pages#1-add-ssh-deploy-key).

## Step 3 | Configure Github User Site

With a site built and push to `master` branch, I setup the repository [to use GitHub user pages](https://help.github.com/en/github/working-with-github-pages) to serve it.

In order to tell my domain `romainlespinasse.dev` to serve my GitHub pages, I just follow the GitHub guideline [to configure an APEX domain](https://help.github.com/en/github/working-with-github-pages/managing-a-custom-domain-for-your-github-pages-site#configuring-an-apex-domain).
In addition of GitHub pages settings and Domain `DNS` settings, I need to add a `CNAME` file to the master branch :

```text
www.romainlespinasse.dev
```

Since the static site is not built by `jekyll` (the default static site generator), I need to add a `.nojekyll` file to the `master` branch.

In `.github/workflows/deploy.yaml` file, I update the `Build` step with :

```yaml
    - name: Build
      run: |
        hugo --gc --minify
        cp CNAME public/
        touch public/.nojekyll
```

Now, [https://romainlespinasse.dev](https://romainlespinasse.dev) is live.
