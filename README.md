# My-K6-Playground

My playground in K6

## Prerequisite

1. (**Warning**) Only run in UNIX or Linux

2. Lua
  - Version >= 5.4
  - Json Library: `lua-json`
    - [luarocks](https://luarocks.org/modules/neoxic/lua-json)
    - [apt](https://zoomadmin.com/HowToInstall/UbuntuPackage/lua-json)

3. [K6](https://github.com/grafana/k6)
  - Version >= 0.4

4. Bash
  - Version >= 4.0

5. ulimit (in UNIX or Linux)

```console
ulimit -n 655350
```

## Quick Start

Execute stress tests according to `CreateTasksWithKey.js` script in K6.

```console
cd ./Scripts/ConstantEnvs
$ lua StartTestsInConstantEnvs.lua CreateTasksWithKey.js 1
```

1. First argument: File name of the script (e.g. `CreateTasksWithKey.js`)
2. Second argument: Pod number (e.g. `1`)

Then, results of stress tests will be automatically generated in `./Results/ConstantEnvs/CreateTasksWithKey_1Pods`

```console
cd ./Results/ConstantEnvs/CreateTasksWithKey_1Pods
$ ls
1_summary_1Pods_R30_D30s_P20_M30.json
2_summary_1Pods_R30_D30s_P20_M30.json
3_summary_1Pods_R30_D30s_P20_M30.json
...
```

### File Name Explaination

File name: `[A]_summary_[B]Pods_[R]30_[D]30s_[P]20_[M]30`

- A: Iteration number (setting in `StartTests*.lua`)
- B: Pod number in the server side
- R: Rate(RPS) (setting in `*ENVs.js`)
- D: Duration time(sec) (setting in `*ENVs.js`)
- P: Pre-allocated vus (setting in `*ENVs.js`)
- M: Max vus (setting in `*ENVs.js`)

## Analyze summary

### ConstantEnvs

To Calculate the average of Rate(RPS), P90 of API Lantency(ms) and P95 API Lantency(ms) in the specific directory, you have to set up directory list first.

e.g. Directory list in `CalSummary.sh`

```bash
# snip...
dirs=("CreateTasksWithKey_10Pods") # line 67
# snip...
```

After that

```console
cd ./Results/ConstantEnvs
$ bash CalSummary.sh
-----
AvgRate:
28
-----
AvgP90:
94
-----
AvgP95:
126
```

Those results will be written into a file named `CalSummary.txt` in `./Results/ConstantEnvs/*Pods/`

```console
cd ./Results/ConstantEnvs/CreateTasksWithKey_1Pods
$ find Summary.txt
Summary.txt
```

To Calculate the average of Rate(RPS), P90 of API Lantency(ms) and P95 API Lantency(ms) including all directories, you have to set up `all` as an argument of `CalSummary.sh`.

```console
cd ./Results/ConstantEnvs
$ bash CalSummary.sh all
-----
AvgRate:
28
-----
AvgP90:
94
-----
AvgP95:
126
-----
AvgRate:
29
-----
AvgP90:
65
-----
AvgP95:
115
```

Those results will be written into the files named `CalSummary.txt` in different directories.

```console
cd ./Results/ConstantEnvs/CreateTasksWithKey_1Pods
$ find Summary.txt
Summary.txt
cd ./Results/ConstantEnvs/CreateTasksWithKey_10Pods
$ find Summary.txt
Summary.txt
```

### ConstantPods

Similar to the content in [ConstantEnvs](#constantenvs). Except that the results will be written into different files named `summary_[\d]*Pods_R[\d]*_D[\d]*s_P[\d]*_M[\d]*.txt`.

### Calculation rules

```plaintext
AvgRate = Sum(Rate of each file) / Total number of files in the same directory (Total interation number)

AvgP90 = Sum(P90 of each file) / Total number of files in the same directory (Total interation number)

AvgP95 = Sum(P95 of each file) / Total number of files in the same directory (Total interation number)
```
