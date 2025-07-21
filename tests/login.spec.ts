import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import users from '../data/users.json';


test.describe('Search Company and Login Application', () => {
  users.forEach(({ testCase, username, password }) => {
    test(`Test Case: ${testCase}`, async ({ page }) => {
      const loginPage = new LoginPage(page);
      
      await loginPage.goto();
      // Now company search
      await loginPage.searchCompany('CX-Operator');

      await loginPage.login(username, password);

    });
  });
});
