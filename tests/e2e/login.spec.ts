import { test, expect } from '@playwright/test';
import { LoginPage } from '../../pages/LoginPage';
import dotenv from 'dotenv';
import { logger } from '../../utils/logger';

// dotenv.config({ path: './env/.env.prod' });

const testCases = [
  {
    TESTCASE: 'Search company and login with valid credentials',
    username: process.env.VALID_USERNAME!,
    password: process.env.VALID_PASSWORD!,
  },
  {
    TESTCASE: 'Search company and login with invalid credentials',
    username: process.env.INVALID_USERNAME!,
    password: process.env.INVALID_PASSWORD!,
  },
];

test.describe('@e2e Search Company and Login Application', () => {
  testCases.forEach(({ TESTCASE, username, password }) => {
    test(TESTCASE, async ({ page }) => {
      const loginPage = new LoginPage(page);
      const baseURL = process.env.BASE_URL!;

      logger.info(`Starting test: ${TESTCASE}`);
      await page.goto(baseURL);
      logger.info(`Navigating to: ${baseURL}`);
      await loginPage.searchCompany('CX-Operator');
      await loginPage.login(username, password);

    });
  });
});
