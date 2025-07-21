import { Page } from '@playwright/test';
import { delay } from '../utils/helpers';
import { test, expect } from '@playwright/test';

export class UserManagement {
  constructor(private page: Page) {}


  async addUser (firstName : string, lastName: string, email:string) {

    await this.page.keyboard.press('PageDown'); // scrolls one page down
    await this.page.getByText('Add User').click();
    await this.page.getByPlaceholder("First Name").fill(firstName);
    await this.page.getByPlaceholder("Last Name").fill(lastName);
    await this.page.getByPlaceholder("Email").fill(email);
    await delay(10000);



  }


}

