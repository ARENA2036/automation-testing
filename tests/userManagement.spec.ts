import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { UserManagement } from '../pages/UserManagementPage';
import dotenv from 'dotenv';
import userManagement from '../data/userManagement.json';
import { Menu } from '../pages/Menu';

dotenv.config({ path: './env/.env.prod' });

test.describe('User Management - Add Multiple Users', () => {
  userManagement.forEach(({ testCase, firstName, lastName, email }) => {
    test(`Add User: ${testCase}`, async ({ page }) => {

      const loginPage = new LoginPage(page);
      const userManagement = new UserManagement(page);
      const menu = new Menu(page);
      const baseURL = process.env.BASE_URL!;
      const username = process.env.USERNAME!;
      const password = process.env.PASSWORD!;

      await page.goto(baseURL);
      await loginPage.searchCompany('CX-Operator');
      await loginPage.login(username, password);

      await menu.menuClick();
      await menu.userMangementTabClick();
      await userManagement.addUser(firstName, lastName, email);
    });
  });
});
