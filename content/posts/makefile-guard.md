---
title: "Makefile: Ensuring Essential Variables with Validation Checks"
date: 2019-07-14T10:00:00+02:00
draft: false
featureimage: /img/posts/makefile/featured.svg
showTableOfContents: false
summary: Explore Makefile nice features to ease your developer life.
tags:
- makefile
categories:
- Tips & Tricks
---

When you use a variable in a Makefile task and you want to make it mandatory and check it before run the effective task,

You can `guard` it

```Makefile
task-who-need-SPECIFIC_ENVVAR: guard-SPECIFIC_ENVVAR
 @echo ${SPECIFIC_ENVVAR}
```

You only need to add the following task

```Makefile
guard-%:
 @ if [ "${${*}}" = "" ]; then \
  echo "Environment variable $* not set"; \
  exit 1; \
 fi
```

So when you run it, the `guard` will prevent to run the task

```shell
$ make task-who-need-SPECIFIC_ENVVAR
Environment variable SPECIFIC_ENVVAR not set
make: *** [guard-SPECIFIC_ENVVAR] Error 1
```

```shell
$ export SPECIFIC_ENVVAR=value
$ make task-who-need-SPECIFIC_ENVVAR
value
```

See [https://stackoverflow.com/a/7367903/1848685](https://stackoverflow.com/a/7367903/1848685)
