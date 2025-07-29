# ilo4_unlock Firmware Flashing Script

## Overview

This shell script automates the process of flashing the iLO4 firmware unlock on supported HP servers. It performs system preparation, installs Python 2.7.18 and necessary dependencies, clones the `ilo4_unlock` repository, builds the patched firmware, and flashes it onto the server.

**Important:** The process requires physical interaction with the server hardware and must be run with root privileges.

---

## Features

- Automatic root privilege enforcement.
- Installs required system packages and dependencies.
- Downloads and compiles Python 2.7.18 (the script and `ilo4_unlock` require this legacy Python version).
- Installs pip for Python 2.7 and sets up a virtual environment.
- Clones the `ilo4_unlock` repository with submodules.
- Builds the patched firmware.
- Safely flashes the firmware with multiple confirmation prompts.
- Ensures the system is safely shut down after flashing.

---

## Usage Instructions

### Prerequisites

- Physical access to the server motherboard to enable the **iLO Security Override Switch**.
- Network access to download required packages and source code.
- The script must be run on a Debian-based system (tested on Ubuntu/Debian).
- Curl must be installed.
- Run this script as root or with sudo privileges.

### Step-by-Step

1. **Physically enable the iLO Security Override Switch** on your server motherboard before running the script.
   
2. **Run the script:**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/t-prior/ILO-Fan-Control/main/install.sh)
```
---

## Fan Control Commands

```
FAN:
Usage:

  info [t|h|a|g|p]
                - display information about the fan controller
                  or individual information.
  g             - configure the 'global' section of the fan controller
  g smsc|start|stop|status
          start - start the iLO fan controller
          stop - stop the iLO fan controller
          smsc - configure the SMSC for manual control
       ro|rw|nc - set the RO, RW, NC (no_commit) options
    (blank)     - shows current status
  t             - configure the 'temperature' section of the fan controller
  t N on|off|adj|hyst|caut|crit|access|opts|set|unset
             on - enable temperature sensor
            off - disable temperature sensor
            adj - set ADJUSTMENT/OFFSET
      set/unset - set or clear a fixed simulated temp (also 'fan t set/unset' for show/clear all)
           hyst - set hysteresis for sensor
           caut - set CAUTION threshold
           crit - set CRITICAL threshold
         access - set ACCESS method for sensor (should be followed by 5 BYTES)
           opts - set the OPTION field
  h             - configure the 'tacHometers' section of the fan controller
  h N on|off|min|hyst|access
             on - enable sensor N
            off - disable sensor N
            min - set MINIMUM tach threshold
           hyst - set hysteresis
 grp ocsd|show  - show grouping parameters with OCSD impacts
  p             - configure the PWM configuration
  p N on|off|min|max|hyst|blow|pctramp|zero|feton|bon|boff|status|lock X|unlock|tickler|fix|fet|access
             on - enable (toggle) specified PWM
            off - disable (toggle) specified PWM
            min - set MINIMUM speed
            max - set MAXIMUM speed
           blow - set BLOWOUT speed
            pct - set the PERCETNAGE blowout bits
           ramp - set the RAMP register
           zero - set the force ZEROP bit on/off
          feton - set the FET 'for off' bit on/off
            bon - set BLOWOUT on
           boff - set BLOWOUT off
         status - set STATUS register
           lock - set LOCK speed and set LOCK bit
         unlock - clear the LOCK bit
        tickler - set TICKLER bit on/off - tickles fans even if FAN is stopped
  pid           - configure the PID algorithm
  pid N p|i|d|sp|imin|imax|lo|hi  - configure PID paramaters
                                  - * Use correct FORMAT for numbers!
             p - set the PROPORTIONAL gain
             i - set the INTEGRAL gain
             d - set the DERIVATIVE gain
            sp - set SETPOINT
          imin - set I windup MIN value
          imax - set I windup MAX value
            lo - set output LOW limit
            hi - set output HIGH lmit
 MISC
  rate X        - Change rate to X ms polling (default 3000)
  ramp          - Force a RAMP condition
  dump          - Dump all the fan registers in raw HEX format
  hyst h v1..vN - Perform a test hysteresis with supplied numbers
  desc <0>..<15> - try to decode then execute raw descriptor bytes (5 or 16)
  actn <0>..<15> - try to decode then execute raw action bytes (5 or 16)
  debug trace|t X|h X|a X|g X|p X|off|on
                - Set the fine control values for the fan FYI level
  DIMM          - DIMM-specific subcommand handler
  DRIVE         - Drive temperature subcommand handler
  MB            - Memory buffer subcommand handler
  PECI          - PECI subcommand handler
 AWAITING DOCUMENTAION
  ms  - multi-segment info
  a N  - algorithms - set parameters for multi-segment.
  w   - weighting

```

## Credits

- **Kendall Goto** — Original creator of the [ilo4_unlock](https://github.com/kendallgoto/ilo4_unlock) project, which this script depends on for unlocking iLO4 firmware.
- **Python Software Foundation** — For the Python 2.7.18 source and ecosystem that enables legacy compatibility.
- **Open Source Community** — For the many libraries and tools leveraged in this script, including `virtualenv`, `pip`, and core Debian packages.
