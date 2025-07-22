import { defineConfig, devices } from '@playwright/test';
import * as dotenv from 'dotenv';
import path from 'path';

const ENV = process.env.ENV || 'dev';
dotenv.config({ path: path.resolve(__dirname, `./env/.env.${ENV}`) });

const desktopChromeNoScale = {
  ...devices['Desktop Chrome'],
  deviceScaleFactor: undefined,
};

const desktopEdgeNoScale = {
  ...devices['Desktop Edge'],
  deviceScaleFactor: undefined,
};

const desktopFirefoxNoScale = {
  ...devices['Desktop Firefox'],
  deviceScaleFactor: undefined,
};

export default defineConfig({
  timeout: 50000,
  testDir: './tests',
  retries: 0,
  use: {
    baseURL: process.env.BASE_URL,
    headless: process.env.CI ? true : false, //Auto headless in CI
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  //##### Add projects for browsers ######//
  projects: [
    {
      name: 'Chrome',
      use: {
        ...desktopChromeNoScale,
        viewport: null,
        launchOptions: {
          args: ['--start-maximized'],
        },
      },
    },
    {
      name: 'Firefox',
      use: {
        ...desktopFirefoxNoScale,
        viewport: null,
      },
    },
    {
      name: 'Edge',
      use: {
        ...desktopEdgeNoScale,
        channel: 'msedge',
        viewport: null,
        launchOptions: {
          args: ['--start-maximized'],
        },
      },
    },
  ],

  reporter: [
    ['list'],
   // ['html', { outputFolder: 'playwright-report', open: 'never' }], /// this is playwright report
    ['allure-playwright'],
  ],
});
