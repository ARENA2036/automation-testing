import { Page } from '@playwright/test';
import { delay } from '../utils/helpers';
import { test, expect } from '@playwright/test';

export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/');
    await delay(5000);
  }

  async searchCompany(companyName: string) {
    await this.page.getByPlaceholder('Enter your company name').fill(companyName);
    await this.page.keyboard.press('Enter');
    await delay(5000);

  }
  async login(username: string, password: string) {
    await this.page.locator('xpath=/html/body/main/div/ul/li/a/div[2]').click();
    await this.page.type('#username', username, { delay: 100 });
    await delay(4000);
    await this.page.fill('#password', password);
    await this.page.click('#kc-login');
    await delay(6000);
    // await expect(this.page.locator('xpath=//*[@id="app"]/header/div/div[1]/a/img')).toBeVisible();
  }

}

