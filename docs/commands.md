# Commands

## Environment
Server: Nobel  
Shell: csh/tcsh  
Simulator: XSim (Vivado 2019.2)

## Repo location
> Update this if your actual server path is different.

```bash
/home/vsudhanvi/rtl-parametric-execute-unit
```

## Go to repo

```bash
cd /home/vsudhanvi/rtl-parametric-execute-unit
pwd
```

## Check tool availability

```bash
which xvlog
which xelab
which xsim
python3 --version
```

## Git status

```bash
git status
git log --oneline -n 5
```

## Smoke runs

### Default 32-bit execute unit, multiply enabled

```bash
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit --waves
```

### 32-bit execute unit, multiply disabled

```bash
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_nomul --waves
```

### 8-bit width regression

```bash
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_8b --waves
```

### 16-bit width regression

```bash
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_16b --waves
```

### 32-bit explicit width regression

```bash
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_32b --waves
```

## Run all wrappers one by one

```bash
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit --waves
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_nomul --waves
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_8b --waves
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_16b --waves
python3 -m scripts.run --tool xsim --suite smoke --test exec_unit_32b --waves
```

## Latest report folder in csh

```bash
set latest=`ls -td reports/run_* | head -1`
echo $latest
```

## Show run info

```bash
cat $latest/run_info.yaml
```

## List generated artifacts

```bash
find $latest -maxdepth 2 -type f | sort
```

## Find waveform database

```bash
find $latest -name "*.wdb"
```

## Open waveform

```bash
xsim $latest/work.sim.wdb -gui &
```

## GUI forwarding direct open

```bash
xsim --gui reports/<run_id>/work.sim.wdb
```

## Check simulator processes

```bash
ps -u $USER | grep xsim | grep -v grep
```

## Check run logs

```bash
set latest=`ls -td reports/run_* | head -1`
echo $latest
grep -nE "TC[0-9][0-9][0-9]|FAIL|ERROR|FATAL|PASS" "$latest/xsim.log"
```

## Check testcase pass/fail lines only

```bash
set latest=`ls -td reports/run_* | head -1`
grep -nE "PASS \[TC|FAIL \[TC" "$latest/xsim.log"
```

## Count testcase pass/fail lines

```bash
set latest=`ls -td reports/run_* | head -1`
echo "PASS count:"
grep -c "PASS \[TC" "$latest/xsim.log"
echo "FAIL count:"
grep -c "FAIL \[TC" "$latest/xsim.log"
```

## Run triage on latest report

```bash
set latest=`ls -td reports/run_* | head -1`
python3 -m scripts.triage $latest
cat $latest/triage.yaml
```

## Generate summary report

```bash
set latest=`ls -td reports/run_* | head -1`
python3 -m scripts.report $latest
cat $latest/summary.md
```

## Full regression helper for whole smoke suite

> Use this only if you want the wrapper-level regression launcher.

```bash
python3 -m scripts.regress --tool xsim --suite smoke --waves
```

## Latest regression folder after regress helper

```bash
set latest=`ls -td reports/run_* | head -1`
echo $latest
find $latest -maxdepth 2 -type f | sort
```

## Open exact waveform from a known run

```bash
xsim reports/run_YYYYMMDD_HHMMSS/work.sim.wdb -gui &
```

## Check compile/elab/sim messages quickly

```bash
set latest=`ls -td reports/run_* | head -1`
grep -nE "ERROR:|FATAL|FAIL|PASS|XSIM|xvlog|xelab" "$latest/xsim.log"
```

## Save latest path into notes manually

```bash
set latest=`ls -td reports/run_* | head -1`
echo $latest >> docs/commands.md
```

## Suggested verification execution order

1. `exec_unit`
2. `exec_unit_nomul`
3. `exec_unit_8b`
4. `exec_unit_16b`
5. `exec_unit_32b`

## Suggested evidence capture targets

Capture screenshots or notes for:
- carry-out addition case
- signed overflow case
- arithmetic right shift on negative value
- signed vs unsigned compare distinction
- branch taken / not taken
- illegal opcode handling
- multiply disabled behavior
- width-specific 8/16/32-bit representative cases

## Optional cleanup of old run folders

> Only do this if you are sure you do not need old generated artifacts.

```bash
rm -rf reports/run_*
```
