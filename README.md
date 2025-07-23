# 🧪 Playwright Automation Framework
This repository delivers a robust Playwright-based automation testing framework for validating Dataspace services across UI and API layers. It supports multi-environment configuration, browser-specific execution, and tagged test runs, leveraging the Page Object Model (POM) for scalable and maintainable test architecture. Comprehensive test reporting is enabled through integration with Allure reports.

## Quick Start:
## Features
- UI & API testing support
- Multi-environment support (`dev`, `qa`, `prod`)
- Tagged test execution (e.g. `@smoke`, `@regression`)
- Logger utility for debugging
- Screenshots and video on test failure
- GitHub Actions CI pipeline
- GitHub Pages deployed Allure report
- Playwright Codegen for test recording
- Cross-browser testing (Chromium, Firefox, WebKit, Edge)
- Custom utilities and reusable Page Object Models
  

### 🛠 Prerequisites :
Make sure these are installed:

- Node.js (v18+)
- Git
- Allure CLI

### 📦 Installation:
#### Install Allure CLI:
- RUN:`npm install -g allure-commandline --save-dev`

#### Clone the repo:
- `git clone https://github.com/ARENA2036/automation-testing.git`
- `cd automation-testing`

#### Install dependencies:
- `npm install`

#### Install Playwright browsers:
- `npx playwright install`

## 📁 Project Structure:

- `tests/` — test specs
- `pages/` — Page Object Models (POM)
- `data/` — test data
- `env/` — environment configs
- `utils/` — custom functions
- `playwright.config.ts` — test config

### 🌐 Environment Setup:
Define your target environment:

`ENV=dev`    # or qa / prod
- This tells the framework to load settings from /env/dev.ts, etc.

#### Run Specific Test:
`ENV=dev npx playwright test tests/login.spec.ts`

#### Run Tests by Browser:
- `ENV=dev npx playwright test --project=Chrome`
- `ENV=dev npx playwright test --project=Firefox`
- `ENV=dev npx playwright test --project=Edge`

### 🏷️ Tagged Test Execution:
Use tags to run a subset of tests:
- Add a tag to a test:
  - `test('@smoke should load login page', async ({ page }) => {
    // your test
  });`

#### Run test with tag:
- `npx playwright test --grep @smoke`
- `npx playwright test --grep @regression`

### 🧰 Logger Utility:
This framework includes a built-in logger utility for structured test logs.
#### Example usage:
* Log levels supported: info, debug, warn, error.
    - `import { logger } from '../utils/logger;`
  
    - `logger.info('Test started');`
    - `logger.warn('This is a warning');`
    - `logger.error('Something went wrong');`

### 🌍 API Testing Support:
You can write API tests using either Playwright’s APIRequestContext or supertest/fetch.
#### Example API Test (Playwright):

`test('GET /users should return 200', async ({ request }) => {
  const response = await request.get('/users');
  expect(response.status()).toBe(200);
});`

#### API tests are usually placed inside:
Run them the same way as UI tests.
- `tests/api/`

### 📊 Reporting:
##### Generate and Open the Allure Report:
 `allure generate allure-results --clean -o allure-report && allure open allure-report`
- This will open the Allure HTML report in your browser.

##### Run tests + Generate both reports in one command:
`ENV=dev npx playwright test --project=Chrome \
&& npx playwright show-report \
&& allure generate allure-results --clean -o allure-report \
&& allure open allure-report`

### 🎥 Screenshots & Video on Failure:
Configured automatically in playwright.config.ts:
- `screenshot: 'only-on-failure',`
- `video: 'retain-on-failure',`
 - `Saved under .playwright/artifacts/. `

### 🧬 Record Tests (Codegen):
Generate code by interacting with the UI:
- `npx playwright codegen https://your-app.com`

## 🤖 GitHub Actions CI:
GitHub Actions in .github/workflows/playwright.yml runs on every push:
### Features:
- Runs cross-browser UI and API tests
- Uploads Playwright + Allure reports as artifacts
- Automatically commits Allure report to gh-pages branch
You’ll see reports in your GitHub Pages URL post-run.

### Cross-Browser Testing:
Supports:
- Chromium
- Firefox
- WebKit
- Edge (via custom config)
Set in playwright.config.ts under projects.

### 📜 Recommended Scripts
- In package.json, add:

- `"scripts": {`
  - `"test:dev": "ENV=dev npx playwright test",`
  - `"test:qa": "ENV=qa npx playwright test",`
  - `"test:prod": "ENV=prod npx playwright test",`
  - `"test:smoke": "npx playwright test --grep @smoke",`
  - `"report:html": "npx playwright show-report",`
  - `"report:allure": "allure generate allure-results --clean -o allure-report && allure open allure-report"`
- `}`

#### Then run:
 - `npm run test:smoke`
 - `npm run report:allure`

#### Automation Testing
This repository contains artifacts to enable dataspace automation testing.
