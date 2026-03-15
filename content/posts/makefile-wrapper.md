---
title: "Makefile: Streamlining Tasks with Wrapper Functions"
date: 2019-10-18T10:00:00+01:00
draft: false
showToC: false
summary: Explore Makefile nice features to ease your developer life.
tags:
  - makefile
  - tips
categories:
  - Technical posts
---

In makefile, you can define tasks and run them individually

> `make run-task1 run-task2 run-task3`

```Makefile
run-task1:
 @echo "run task 1"

run-task2:
 @echo "run task 2"

run-task3:
 @echo "run task 3"
```

When you want to run tasks from another tasks (e.g. `make run-all-tasks`), you can

* use [`makefile` prerequisites mechanism](https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html#Prerequisite-Types)

```Makefile
run-all-tasks: run-task1 run-task2 run-task3
```

* use sub-command line with [`$(MAKE)`](https://www.gnu.org/software/make/manual/html_node/MAKE-Variable.html)

```Makefile
run-all-tasks:
 @$(MAKE) run-task1
 @$(MAKE) run-task2
 @$(MAKE) run-task3
```

You can also create a `wrapper` task to run all tasks with a specific naming.

> This will enable you to don't known all task names.
> Useful when using `include` mechanism in your makefile.

```Makefile
include makefile-with-run-tasks.mk

run-all-tasks:
 @grep -E '^[\.a-zA-Z0-9_%-]+:.*$$' $(MAKEFILE_LIST) \
  | cut -d ":" -f2 | grep "^run-task" | sort -u \
  | xargs $(MAKE)
```

So when you run it, the `run-all-tasks` task will run all `run-task` tasks.

```shell
$ make run-all-tasks
run task 1
run task 2
run task 3
```
