import { test, expect } from '@playwright/test';
import { LoginPage } from '../../pages/LoginPage';
import { UserManagement } from '../../pages/UserManagementPage';
import userManagement from '../../data/userManagement.json';
import { Menu } from '../../pages/Menu';
import { logger } from '../../utils/logger';

test.describe('@e2e User Management - Add Multiple Users', () => {
  userManagement.forEach(({ testCase, firstName, lastName, email }) => {
    test(`Add User: ${testCase}`, async ({ page }) => {

      const loginPage = new LoginPage(page);
      const userManagement = new UserManagement(page);
      const menu = new Menu(page);
      const baseURL = process.env.BASE_URL!;
      const username = process.env.USERNAME!;
      const password = process.env.PASSWORD!;

      logger.info(`Starting test: ${testCase}`);
      await page.goto(baseURL);
      logger.info(`Navigating to: ${baseURL}`);
      await loginPage.searchCompany('CX-Operator');
      logger.info(`Logging in`);
      await loginPage.login(username, password);
      await menu.menuClick();
      await menu.userMangementTabClick();
      logger.info(`Adding user: ${firstName} ${lastName} - ${email}`);
      await userManagement.addUser(firstName, lastName, email);
    });
  });
});
