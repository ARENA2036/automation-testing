import { Page } from '@playwright/test';
import { delay } from '../utils/helpers';
import { test, expect } from '@playwright/test';

export class Menu {
  constructor(private page: Page) {

  }
////// Right Menu//////
  async menuClick() {
    await this.page.click('css=.UserInfo.MuiBox-root.css-0');
    await delay(5000);

  }

////// User Management Panel //////
 async userMangementTabClick() {
    await this.page.click('a[href="/userManagement"]');
    await delay(5000);

  }

}