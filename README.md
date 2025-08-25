# WIP Overview

- Static site in `site/` deployed on Netlify
- Data file: `site/data/inventory.json` produced by `scripts/publish-inventory.ps1`
- Schedule: hourly between 08:00 and 17:00 via Windows Task Scheduler

## First run
- Create DB credential: secrets/db_cred.xml
- Run scripts/env-check.ps1
- Run scripts/publish-inventory.ps1 (manually) to produce first data
