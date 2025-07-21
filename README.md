# Playwright Automation Framework

## Structure

- `tests/` — test specs
- `pages/` — Page Object Models (POM)
- `data/` — test data
- `env/` — environment configs
- `utils/` — custom functions
- `playwright.config.ts` — test config

## Run Tests

##### bash
ENV=dev npx playwright test
ENV=qa npx playwright test
ENV=prod npx playwright test

##### Run Tests Project Browser
ENV=dev npx playwright test --project=Chrome
ENV=dev npx playwright test --project=Firefox
ENV=dev npx playwright test --project=Edge


##### Generate and Open the Allure Report
allure generate allure-results --clean -o allure-report && allure open allure-report
- This will open the Allure HTML report in your browser.

##### Run tests + generate both reports in one command
ENV=dev npx playwright test --project=Chrome \
&& npx playwright show-report \
&& allure generate allure-results --clean -o allure-report \
&& allure open allure-report

This will:
1. Run the test.
2. Generate the Allure report.
3. Open the Allure report in your browser.

# Automation Testing
This repository contains artifacts to enable dataspace automation testing.