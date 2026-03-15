---
title: "Homebrew : Optimisez la gestion de paquets sur macOS"
date: 2017-02-28T10:42:00+01:00
draft: false
summary: Découvrez homebrew pour vous facilitez la vie sous macOS dans la gestion de vos installations de packages.
images: 
- /img/posts/homebrew/featured.jpg
tags:
- homebrew
- macos
- french
categories:
- Technical posts
---

Votre société ou votre client vient de vous confier un macbook pour travailler, il ne vous reste plus qu'à installer tout un ensemble de programmes pour commencer.

Sous linux, vous auriez un gestionnaire de formulas qui ferait bien l'affaire pour aller plus vite.
Mais sous macOS, pas de apt-get, pas de yum, vous voilà parti pour installer tout cela à la main.

Pas de crainte, des gestionnaires de formulas existent aussi pour macOS comme [**Homebrew**](http://brew.sh/) (ou [MacPorts](https://www.macports.org)).

Installer homebrew en une ligne de commande :

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

> **Homebrew** est un gestionnaire basé sur des **formulas** d'installation de formula (en _Ruby_) et utilise des _repositories git_ comme conteneurs de ces **formulas**.

Après une simple installation, vous avez à votre disposition une nouvelle commande, petit tour du proprietaire :

La commande **"brew"** vous montre les commandes les plus courantes :

```shell
$ brew
Example usage:
  brew search [TEXT|/REGEX/]
  brew (info|home|options) [FORMULA...]
  brew install FORMULA...
  brew update
  brew upgrade [FORMULA...]
  brew uninstall FORMULA...
  brew list [FORMULA...]

Troubleshooting:
  brew config
  brew doctor
  brew install -vd FORMULA
```

Dans ces commandes, on retourne notamment celles pour gérer le _cycle de vie de votre formula_ :

```shell
brew install FORMULA...
brew update
brew upgrade [FORMULA...]
brew uninstall FORMULA...
```

> [!TIP]
> En executant `brew doctor`, vous vérifiez que votre installation de Homebrew est correcte.
> La commande vous indiquera les différents problèmes de votre installation (s'il y en a).

Maintenant que homebrew est installé, vous souhaitez installer vos premiers formulas.

Vous commencez par vos besoins pour le projet.
Comme il s'agit d'un projet en **Java** sous **Gradle** avec des outils écrits en **Go** et que l'ensemble est géré par Ansible, vous avez votre liste de formulas:

* Ansible
* Java
* Go
* Gradle

Vous installez vos formulas hors java

```shell
$ brew install ansible go gradle

$ ansible --version
ansible 2.2.0.0

$ go version
go version go1.7.4 darwin/amd64

$ gradle -v
Gradle 3.3
```

Vous installer java à part, car vous souhaitez installer java 8.

Vous rechercher donc les **formulas** nommées **java** :

```shell
$ brew search java
app-engine-java
google-java-format
javarepl
jslint4java
libreadline-java
homebrew/emacs/javaimp
Caskroom/cask/eclipse-java
Caskroom/cask/java
Caskroom/cask/netbeans-java-ee
Caskroom/cask/netbeans-java-se
Caskroom/cask/yourkit-java-profiler
Caskroom/versions/charles-applejava
Caskroom/versions/charles-beta-applejava
Caskroom/versions/java-beta
Caskroom/versions/java6
Caskroom/versions/java7
Caskroom/versions/java9-beta
```

**Aie**, il n'y a pas de _formula_ nommée **java** ou **java8**.
Par contre la recherche vous propose les formulas contenant le mot **java**.
Parmis les formulas, ceux avec un chemin (**a/b/formula**) sont des formulas contenues dans des **taps**.

**Mais qu'est-ce qu'un tap**, il s'agit d'un autre **repository git**
contenant des formulas dédiées ou des nouvelles commandes.

* On installe un **tap** via la commande `brew tap utilisateur/nom_tap`,
* Avec le tap **utilisateur/nom_tap**, brew installera le _repository git_ associé à l'url [https://github.com/utilisateur/homebrew-nom_tap](https://github.com/utilisateur/homebrew-nom_tap),
* Pour les autres possibilités, utilisez `brew tap -h`.

> [!TIP]
> `brew install a/b/formula` installera le **tap** et la formula en même temps.

Parmis les **taps** officiels, on peut trouver :

* [**homebrew/core**](https://github.com/Homebrew/homebrew-core) - _Core formulae for the Homebrew formula manager_ **(the default tap)**
* [**homebrew/science**](https://github.com/Homebrew/homebrew-science) - _Scientific formulae for the Homebrew formula manager_
* [**homebrew/games**](https://github.com/Homebrew/homebrew-games) - _Games formulae for the Homebrew formula manager_
* [**homebrew/completions**](https://github.com/Homebrew/homebrew-completions) - _Shell completion formulae for the Homebrew formula manager_
* [**homebrew/command-not-found**](https://github.com/Homebrew/homebrew-command-not-found) - _Ubuntu's command-not-found equivalent for Homebrew on OSX_
* [**homebrew/services**](https://github.com/Homebrew/homebrew-services) - _Starts Homebrew formulae's plists with launchctl_

Tous ces **taps** sont gérés par la communauté Homebrew, mais certains **taps** officiels ne sont pas de Homebrew mais sont bien intégrés comme **Caskroom/cask**.

Les **formulas** de **Caskroom/cask** sont dédiés aux installations d'applications macOS.

Maintenant, vous installez **java 8** :

```shell
$ brew install Caskroom/cask/java
==> brew cask install Caskroom/cask/java
...

$ java -version
java version "1.8.0_112"
Java(TM) SE Runtime Environment (build 1.8.0_112-b16)
Java HotSpot(TM) 64-Bit Server VM (build 25.112-b16, mixed mode)
```

Lors du lancement de la commande, brew a transféré votre demande à `brew cask install` pour son installation.

Avec **Cask**, vous pouvez, en plus de vos formulas, installer votre navigateur, votre éditeur de code, ...

```shell
brew cask install google-chrome intellij-idea docker slack
```

> [!TIP]
>
> * `brew tap caskroom/drivers` vous permet d'installer les drivers pour macOS.
> * Les fonts s'installent elles via `brew tap caskroom/fonts`.

Certains formulas sont gérées comme des **services** via macOS **launchd**.
Pour cela, brew propose, via [**homebrew/services**](https://github.com/Homebrew/homebrew-services),
la commande **brew services** pour faciliter leurs utilisations.

Pour votre projet, vous avez aussi besoin d'une base de données **MySQL**.

Vous installez **MySQL** qui possède un service sous macOS :

```shell
$ brew install mysql

$ brew services list
Name           Status  User Plist
mysql          stopped

$ brew services start mysql
==> Successfully started `mysql` (label: homebrew.mxcl.mysql)

$ brew services list
Name           Status  User            Plist
mysql          started <your_username> ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
```

Votre installation de poste est terminée.
Vous pouvez commencer à travailler.

Au bout d'un certain temps, vous souhaiteriez mettre à jour vos formulas.

La procédure de mise à jour se fait en deux commandes **update** + **upgrade**.
Avec ces 2 commandes, vous pouvez aussi utiliser deux autres commandes **outdated** et **cleanup** utiles suivant vos besoins.

* **update** met à jour les _repositories git_ des **taps**,

  ```shell
  $ brew update
  Updated 2 taps (caskroom/cask, homebrew/core).
  ==> New Formulae
  ==> Updated Formulae
  go ✔
  ```

* **upgrade** met à jour les formulas,

  ```shell
  $ brew upgrade
  ==> Upgrading 1 outdated formula, with result:
  go 1.7.4_1
  ==> Upgrading go
  ==> Downloading https://homebrew.bintray.com/bottles/go-1.7.4_1.sierra.bottle.tar.gz
  ...
  🍺  /usr/local/Cellar/go/1.7.4_1: 6,438 files, 250.7M
  ```

* **outdated** liste les formulas qui doivent être mis à jour,

  ```shell
  $ brew outdated
  go (1.6) < 1.7.4_1
  ```

* **cleanup** supprime les anciennes versions des formulas (car Homebrew les garde indéfiniment).

  ```shell
  $ brew cleanup
  Removing: /usr/local/Cellar/go/1.6... (6,438 files, 250.7M)
  ==> This operation has freed approximately 250.7M of disk space.
  ```

> Définissez un alias **bubu** (déjà disponible par défaut dans **zsh**) pour `brew update && brew outdated && brew upgrade && brew cleanup`, et ainsi en une commande gèrer vos formulas plus simplement.

Vous venez d'apprendre qu'un des mécanismes par défaut de Homebrew est de conserver toutes les versions installées de vos formulas.
Ceci dans le but de vous permettre de facilement switcher entre ces versions.

> **brew install \<formula>** ne permet d'installer que la version courante du formula, jamais une ancienne version.

Par exemple comment passer à une version go 1.6 puis revenir sur une version go 1.7 :

```shell
$ brew switch go 1.6
Cleaning /usr/local/Cellar/go/1.6
Cleaning /usr/local/Cellar/go/1.7.4_1
3 links created for /usr/local/Cellar/go/1.6

$ brew switch go 1.7.4_1
Cleaning /usr/local/Cellar/go/1.6
Cleaning /usr/local/Cellar/go/1.7.4_1
3 links created for /usr/local/Cellar/go/1.7.4_1
```

> [!TIP]
> Le tap **homebrew/versions** vous permet d'accèder à d'anciennes versions.

Sur le projet, votre voisin de bureau commence sa première journée et vous demande de lui passer votre liste de formulas et d'applications pour faire lui aussi l'installation rapidement.

Vous appliquez la méthode KISS :

```shell
brew list > brew-formulas.txt
brew cask list > brew-applications.txt
```

Et votre voisin devrait se débrouiller avec les deux fichers bruts que vous venez de lui envoyer par email.
C'est KISS mais seulement pour vous.

Mais là encore, Homebrew a pensé à faciliter ce genre d'actions via **brew bundle**.

Vous créez un Brewfile de votre poste via `brew bundle dump` :

```shell
$ brew bundle dump
$ cat Brewfile
tap 'caskroom/cask'
tap 'homebrew/bundle'
tap 'homebrew/core'
tap 'homebrew/services'
brew 'ansible'
brew 'go'
brew 'mysql', restart_service: true
brew 'gradle'
cask 'docker'
cask 'google-chrome'
cask 'intellij-idea'
cask 'java'
cask 'slack'
```

Un fichier _Brewfile_ commence par lister les **taps** installés, puis les formulas installés, ainsi que les applications.
Il garde même en mémoire les status des services (ici, **mysql** est lancé).

Vous transmettez le fichier **Brewfile** à votre voisin et il n'a plus qu'à l'utiliser.

Votre voisin de bureau installe ce Brewfile sur son poste :

```shell
$ brew bundle
Tapping caskroom/cask
Tapping homebrew/bundle
Using homebrew/core
Tapping homebrew/services
Installing ansible
Installing go
Installing gradle
Installing mysql
Installing docker
Installing google-chrome
Installing intellij-idea
Installing java
Installing slack
```

> [!TIP]
> Par défaut, **brew bundle** utilise le fichier **Brewfile** depuis le dossier courant.
>
> * L'option `--file=path` permet de définir un autre chemin vers le fichier **Brewfile**.
> * L'option `--global` ira lire un fichier **.Brefile** depuis votre **$HOME**.

Après la découverte de **brew bundle**,
vous vous dites autant partager la liste des formulas nécessaire pour un projet spécifiquement.

Pour cela, il suffit de créer un fichier **Brewfile** dans vos sources de projet et de le commiter.
Comme cela un nouveau développeur n'a qu'à lancer `brew bundle` pour être sûr d'avoir le nécessaire pour travailler sur le projet.

Cela tombe bien, vous avez un nouveau projet en Java sous Gradle à faire et qui servira comme outil aux autres développeurs.

Vous créez un **Brewfile** dans votre nouveau projet avec Java et Gradle

```shell
$ cd project-tool
$ vim Brewfile
$ cat Brewfile
tap 'caskroom/cask'
brew 'gradle'
cask 'java'
```

Après que ce nouveau projet soit prêt, il est temps que les autres développeurs l'utilisent.
Pour faciliter sa distribution, vous l'avez publié dans votre repository manager de votre client (ex. **Nexus**).

Un de vos collègues teste l'installation du nouvel outil :

```shell
$ tool_url='https://nexus.client.tld/content/repositories/releases/tld/client/project/tool/1.0.0/tool-1.0.0-distribution.zip'
$ wget $tool_url
$ unzip tool-1.0.0-distribution.zip
$ tree
tool-1.0.0-distribution
├── bin
│   └── tool
└── lib
    └── tool-1.0.0.jar
$ chmod u+x tool-1.0.0-distribution/bin/tool
$ echo "export PATH=\"$(pwd)/tool-1.0.0-distribution/bin:\$PATH\"" >> ~/.bashrc
$ . ~/.bashrc
$ tool --version
1.0.0
```

Mais la procédure d'installation n'est pas aussi simple que d'écrire `brew install project-tool`.
Pourquoi ne pas créer une **formula** aussi pour ce projet?

Avant de la créer, vous vous demandez comment la sauvegarder?
Homebrew vous propose déjà des **taps** pour avoir plus de **formulas** disponibles.

Vous pouvez créer un **tap** privé qui est un simple repository git.
Par défaut, un _tap_ ajouté via `brew tap utilisateur/nom_tap` corresponds à l'url [https://github.com/utilisateur/homebrew-nom_tap.git](https://github.com/utilisateur/homebrew-nom_tap.git).

Si vous voulez le stocker ailleurs, l'ajout se fait par `brew tap utilisateur/nom_tap git@git.client.tld:utilisateur/homebrew-nom_tap.git`.

> [!NOTE]
> Dans un **Brewfile**, ajouter la ligne `tap 'utilisateur/nom_tap', 'git@git.client.tld:utilisateur/homebrew-nom_tap.git'` pour déclarer ce tap.

Une fois que vous avez créé et ajouté ce **tap** privé, vous pouvez passer à la création de la **formula** via la commande `create`.

```shell
$ brew create $tool_url --set-name project-tool --set-version 1.0.0 --tap utilisateur/nom_tap
==> Downloading https://nexus.client.tld/content/repositories/releases/tld/client/project/tool/1.0.0/tool-1.0.0-distribution.zip
######################################################################## 100,0%
Please `brew audit --new-formula project-tool` before submitting, thanks.
Editing /usr/local/Homebrew/Library/Taps/utilisateur/nom_tap/project-tool.rb
```

Suite à la création de votre **formula**, homebrew ouvre automatiquement le fichier associé :

```ruby
# Documentation: http://docs.brew.sh/Formula-Cookbook.html # <1>
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class ProjectTool < Formula
  desc ""
  homepage ""
  url "https://nexus.client.tld/content/repositories/releases/tld/client/project/tool/1.0.0/tool-1.0.0-distribution.zip" # <2>
  version "1.0.0"
  sha256 "12259beb7c5a0954f2193f581a0c11ec63ff4a573ffeb35efba4b6389d36fad7"

  # depends_on "cmake" => :build # <3>

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    # Remove unrecognized options if warned by configure
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    # system "cmake", ".", *std_cmake_args
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test project-tool`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
```

> 1. La formula vous fournie le lien vers la documentation pour finir sa création,
> 2. La formula contient déjà les informations données (ex. url, version) ou générées (ex. sha256),
> 3. Le reste du code est un template par défaut.

Vous pouvez **auditer** la formula pour savoir par où commencer

```shell
$ brew audit --new-formula project-tool
utilisateur/nom_tap/project-tool:
  * Formula should have a desc (Description).
  * The homepage should start with http or https (URL is ).
  * The homepage  is not reachable (HTTP status code 000)
  * Please remove default template comments
  * Please remove default template comments
  * Commented-out dep "cmake" => :build
  * Please remove default template comments
  * Please remove default template comments
  * Commented cmake call found
  * Please remove default template comments
Error: 10 problems in 1 formula
```

Vous devez donc définir la **description** et la **homepage** de la formula (ex. l'url du repository git).
Et comme il ne s'agit pas d'un _build cmake_, vous pouvez enlever les commentaires ainsi que le code lié à _cmake_.

Vous faites les premiers changements afin que l'audit passe :

```ruby
class ProjectTool < Formula
  desc "Installer l'outil 'tool' pour le projet"
  homepage "https://git.client.tld/project/tool"
  url "https://nexus.client.tld/content/repositories/releases/tld/client/project/tool/1.0.0/tool-1.0.0-distribution.zip"
  version "1.0.0"
  sha256 "12259beb7c5a0954f2193f581a0c11ec63ff4a573ffeb35efba4b6389d36fad7"

  def install
    # Il ne reste plus qu'à faire la procédure d'installation
  end

  test do
    # Et tester la formula
    system "false"
  end
end
```

Puis vous auditez et tentez d'installer la formula :

```shell
$ brew audit --new-formula project-tool
$ brew install project-tool
==> Installing project-tool from utilisateur/nom_tap
==> Downloading https://nexus.client.tld/content/repositories/releases/tld/client/project/tool/1.0.0/tool-1.0.0-distribution.zip
Already downloaded: /Users/utilisateur/Library/Caches/Homebrew/project-tool-1.0.0.zip
Error: Empty installation
```

L'audit est bien passé, mais l'installation de la formula vous indique que la procédure d'installation reste à faire.

La procédure d'installation manuelle vous sert de guide dans l'écriture de votre formula :

1. Télécharger le zip,
2. Décompresser le zip,
3. Aller dans le dossier décompressé,
4. Rendre éxecutable le script **bin/tool**,
5. Ajouter le dossier **bin** au _PATH_,
6. Tester que `tool --version` donne bien le numéro de version de l'outil.

Homebrew téléchargera et décompressera le zip du projet automatiquement (via **url** et **sha256**) réalisant les étapes 1 et 2.

Pour l'étape 3, la fonction **install** s'éxecute dans le dossier décompressé.
Par contre, ce dossier est temporaire, vous devez demander à garder les dossiers **bin** et **lib** dans _libexec_.

Une **formula** propose plusieurs répertoires pour stocker des fichiers utiles.
Le dossier **libexec** sert à stocker des fichiers uniquement nécessaire à la **formula**.
Via `libexec.install`, vous pouvez demander qu'un dossier y soit stocké.

Afin de réaliser l'étape 4, vous devez demander à lier le script **libexec/bin/tool** au PATH via `bin.install_symlink`.
Cette action réalise également l'étape 5 car `bin.install_symlink` gére aussi les permissions.

Le test de l'étape 6 se fera par `brew test`, ceci une fois la fonction **test** remplie dans la _formula_.
Ce test peut simplement être que l'éxecution de `tool --version` fonctionne.

De plus, une formula peut définir des pré-requis comme par exemple que Java 8 (ou plus) soit installé.
Via `depends_on :java => "1.8+"` vous définissez un tel prérequis.

Vous ajoutez les différentes étapes dans la formula :

```ruby
class ProjectTool < Formula
  desc "Installer l'outil 'tool' pour le projet"
  homepage "https://git.client.tld/project/tool"
  url "https://nexus.client.tld/content/repositories/releases/tld/client/project/tool/1.0.0/tool-1.0.0-distribution.zip"
  version "1.0.0"
  sha256 "12259beb7c5a0954f2193f581a0c11ec63ff4a573ffeb35efba4b6389d36fad7"

  depends_on :java => "1.8+"

  def install
    libexec.install %w[bin lib]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/tool", "--version"
  end
end
```

Afin de correctement tester cette **formula**, vous devez

* l'auditer avec `brew audit`,
* l'installer avec `brew install`,
* la tester avec `brew test`.

```shell
$ brew audit --new-formula project-tool
$ brew install project-tool
==> Installing project-tool from utilisateur/nom_tap
==> Downloading https://nexus.client.tld/content/repositories/releases/tld/client/project/tool/1.0.0/tool-1.0.0-distribution.zip
Already downloaded: /Users/utilisateur/Library/Caches/Homebrew/project-tool-1.0.0.zip
🍺  /usr/local/Cellar/project-tool/1.0.0: 4 files, 100K, built in 0 seconds
 $ brew test project-tool
Testing utilisateur/nom_tap/project-tool
==> Using the sandbox
==> /usr/local/Cellar/project-tool/1.0.0/bin/tool --version
```

> Vous pouvez aussi vérifier le style de la formula via `brew style`.

Comme tout s'est bien passé, vous souhaitez maintenant la **commiter** pour que vos collègues puissent l'installer plus simplement.

```shell
cd $(brew --repo utilisateur/nom_tap)
git add Formula/project-tool.rb
git commit
```

Votre collègue apprécie la nouvelle procédure :

```shell
brew tap utilisateur/nom_tap git@git.client.tld:utilisateur/homebrew-nom_tap.git
brew install project-tool
```

> [!NOTE]
> Le système de **formula** permet également de gérer l'installation depuis les sources ([**--HEAD**](https://github.com/Homebrew/brew/blob/master/docs/Formula-Cookbook.md#head))
ou les versions bêta ([**--devel**](https://github.com/Homebrew/brew/blob/master/docs/Formula-Cookbook.md#devel)).
> La documentation des formulas vous permettera d'approfondir vos formulas ([http://docs.brew.sh/Formula-Cookbook.html](http://docs.brew.sh/Formula-Cookbook.html)).

Maintenant que vous savez créer des **formulas** pour votre client, vous pouvez aussi créer des formulas ou les maintenir sur les **taps** officiels.

Pour contribuer, la formula dans les taps officiels (comme **homebrew-core**) doit respecter [certaines conditions pour être acceptable](https://github.com/Homebrew/brew/blob/master/docs/Acceptable-Formulae.md).

Le projet installé par la formula doit être

* open-source,
* stable, maintenu, connu, et utilisé,
* installable depuis ces sources.

Une fois la formula créée ou modifiée, vous pouvez créer une pull-request vers le project **homebrew-core**.
Votre pull-request sera automatiquement analysée et validée par [bot.brew.sh](https://bot.brew.sh/).

Dans le but d'aider les mainteneurs du projet, [bot.brew.sh](https://bot.brew.sh/) traite toutes pull-requests en testant la formula sur les trois dernières versions supportées de macOS (_yosemite, el capitan, et sierra_).

Concernant votre projet **tool**, il ne vous reste plus qu'à le rendre open-source et proposer votre **formula** sur **homebrew-core** quand le projet sera plus connu.

En attendant ce jour, n'hesitez pas à contribuer sur les formulas existantes et rejoindre les 6200 contibuteurs de **homebrew-core**.

Cet article a été publié en premier sur [lemag.sfeir.com](https://sfeir.com).
